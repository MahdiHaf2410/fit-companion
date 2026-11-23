// Fit Companion: image analysis with Gemini (food photos, product labels, body progress).
// Images arrive base64 in the request and are NOT stored anywhere.
// Secrets: GEMINI_API_KEY (required), GEMINI_MODEL (optional).
// verify_jwt is OFF (ES256 user tokens); we authenticate with auth.getUser().
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { generate, modelList } from "./gemini.ts";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
const LIMITS: Record<string, number> = { food_photo: 60, label: 60, progress: 10 };
const MAX_IMAGE_B64 = 6_000_000; // ~4.5 MB per image

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });
}
const num = (v: unknown) => (typeof v === "number" && isFinite(v) && v >= 0 ? v : 0);
const r1 = (v: number) => Math.round(v * 10) / 10;

/** Keeps macros physically consistent per 100 g: P+C+F <= 100 and kcal ≈ 4P+4C+9F. */
function fixPer100(p: number, c: number, f: number, kcal: number) {
  const mass = p + c + f;
  if (mass > 100) {
    const k = 100 / mass;
    p *= k; c *= k; f *= k;
  }
  const atwater = 4 * p + 4 * c + 9 * f;
  if (kcal <= 0 || Math.abs(kcal - atwater) / Math.max(atwater, 1) > 0.15) kcal = atwater;
  return { kcal: r1(kcal), protein: r1(p), carbs: r1(c), fat: r1(f) };
}

const macroItem = {
  type: "OBJECT",
  properties: {
    name: { type: "STRING" },
    grams: { type: "NUMBER" },
    kcal: { type: "NUMBER" },
    protein: { type: "NUMBER" },
    carbs: { type: "NUMBER" },
    fat: { type: "NUMBER" },
  },
  required: ["name", "grams", "kcal", "protein", "carbs", "fat"],
};

const SCHEMAS: Record<string, unknown> = {
  food_photo: {
    type: "OBJECT",
    properties: {
      is_food: { type: "BOOLEAN" },
      dish_name: { type: "STRING" },
      items: { type: "ARRAY", items: macroItem },
      confidence: { type: "STRING", enum: ["high", "medium", "low"] },
      analysis: { type: "STRING" },
      suggestions: { type: "ARRAY", items: { type: "STRING" } },
    },
    required: ["is_food", "dish_name", "items", "confidence", "analysis", "suggestions"],
  },
  label: {
    type: "OBJECT",
    properties: {
      product_name: { type: "STRING" },
      brand: { type: "STRING" },
      read_from_label: { type: "BOOLEAN", description: "true if values were read from a visible nutrition table" },
      kcal_per_100g: { type: "NUMBER" },
      protein_per_100g: { type: "NUMBER" },
      carbs_per_100g: { type: "NUMBER" },
      fat_per_100g: { type: "NUMBER" },
      fiber_per_100g: { type: "NUMBER" },
      serving_g: { type: "NUMBER" },
      confidence: { type: "STRING", enum: ["high", "medium", "low"] },
      notes: { type: "STRING" },
    },
    required: ["product_name", "read_from_label", "kcal_per_100g", "protein_per_100g", "carbs_per_100g", "fat_per_100g", "confidence"],
  },
  progress: {
    type: "OBJECT",
    properties: {
      comparable: { type: "BOOLEAN", description: "false if photos are too different (pose/light) or not body photos" },
      summary: { type: "STRING" },
      progress_score: { type: "NUMBER", description: "0-10, 5 = no visible change" },
      muscle_gain: { type: "STRING", enum: ["clear", "slight", "none", "unclear"] },
      fat_change: { type: "STRING", enum: ["less", "same", "more", "unclear"] },
      areas: {
        type: "ARRAY",
        items: {
          type: "OBJECT",
          properties: { area: { type: "STRING" }, change: { type: "STRING", enum: ["improved", "same", "declined", "unclear"] }, note: { type: "STRING" } },
          required: ["area", "change", "note"],
        },
      },
      tips: { type: "ARRAY", items: { type: "STRING" } },
      photo_tips: { type: "STRING" },
    },
    required: ["comparable", "summary", "progress_score", "muscle_gain", "fat_change", "areas", "tips"],
  },
};

function prompt(mode: string, lang: string, body: Record<string, unknown>): string {
  const L = lang === "ar" ? "Arabic (simple, Algerian-friendly)" : "English";
  const ctx = String(body.context ?? "").slice(0, 3000);
  if (mode === "food_photo") {
    return [
      "You are an expert dietitian analysing a photo of a meal, plate, drink or packaged food.",
      "Identify every distinct food item, estimate its edible weight in grams from visual cues (plate ~26 cm, spoon, hand, packaging) and give kcal, protein, carbs and fat FOR THAT WEIGHT.",
      "Use reference tables (USDA FoodData Central, CIQUAL, Maghreb/Algerian dishes). Include visible oil/sauce/bread. Each item must satisfy kcal ≈ 4*protein + 4*carbs + 9*fat.",
      "analysis: 2-3 short sentences on the nutritional quality of the meal for someone who trains.",
      "suggestions: ONLY if the meal clearly lacks something important (e.g. too little protein for a training goal, no vegetables, too much fat), give 1-3 concrete additions with quantities. If the meal is already good, return an EMPTY array.",
      "If the image is not food, set is_food=false and return empty items.",
      body.note ? `User note: ${String(body.note).slice(0, 300)}` : "",
      ctx ? `User context: ${ctx}` : "",
      `Write dish_name, item names, analysis and suggestions in ${L}.`,
    ].join("\n");
  }
  if (mode === "label") {
    return [
      "Identify this packaged food product. If a nutrition facts table is visible, READ the per-100 g values exactly (convert kJ to kcal if needed) and set read_from_label=true.",
      "Otherwise estimate typical per-100 g values for this exact product/brand from your knowledge and set read_from_label=false with lower confidence.",
      body.barcode ? `Barcode: ${String(body.barcode).slice(0, 32)}` : "",
      body.name ? `Known product name: ${String(body.name).slice(0, 200)}` : "",
      "serving_g: the serving/portion size printed on the pack if visible, else a typical portion.",
      `Write product_name and notes in ${L}. Values must satisfy kcal ≈ 4*protein + 4*carbs + 9*fat per 100 g.`,
    ].join("\n");
  }
  return [
    "You are an experienced physique coach. Compare the BEFORE photo(s) (first) with the AFTER photo(s) (last) of the same person.",
    "Assess visible changes in muscle size/definition per area (shoulders, chest, arms, back, abs/waist, legs) and body fat. Be honest and specific; if lighting, pose or distance differ too much, set comparable=false and explain in photo_tips how to take comparable photos.",
    "Do not comment on attractiveness; focus on training progress. No medical claims.",
    "tips: 3-6 concrete, prioritised actions (training volume, progressive overload, protein g/kg, calories, sleep) based on what you see and the data below.",
    `Photo dates/poses: ${String(body.photo_info ?? "").slice(0, 400)}`,
    ctx ? `User data: ${ctx}` : "",
    `Write everything in ${L}.`,
  ].join("\n");
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.startsWith("Bearer ")) return json({ error: "unauthorized" }, 401);
  const supabase = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: authHeader } },
  });
  const { data: userData, error: userError } = await supabase.auth.getUser(authHeader.slice(7));
  if (userError || !userData.user) return json({ error: "unauthorized" }, 401);

  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) return json({ error: "missing_gemini_key" }, 503);
  const preferred = Deno.env.get("GEMINI_MODEL");
  const models = modelList(preferred);

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_json" }, 400);
  }
  const mode = String(body.mode ?? "");
  if (!(mode in SCHEMAS)) return json({ error: "bad_mode" }, 400);
  const lang = body.language === "ar" ? "ar" : "en";
  const images = Array.isArray(body.images) ? body.images.slice(0, 4) : [];
  if (mode !== "label" && images.length === 0) return json({ error: "no_image" }, 400);
  if (mode === "progress" && images.length < 2) return json({ error: "need_two_photos" }, 400);
  const parts: Record<string, unknown>[] = [];
  for (const img of images) {
    const data = String((img as Record<string, unknown>)?.data ?? "");
    const mime = String((img as Record<string, unknown>)?.mime ?? "image/jpeg");
    const label = (img as Record<string, unknown>)?.label;
    if (!data || data.length > MAX_IMAGE_B64 || !mime.startsWith("image/")) return json({ error: "bad_image" }, 400);
    if (label) parts.push({ text: String(label).slice(0, 120) });
    parts.push({ inlineData: { mimeType: mime, data } });
  }

  const since = new Date(Date.now() - 24 * 3600 * 1000).toISOString();
  const { count } = await supabase
    .from("ai_usage")
    .select("id", { count: "exact", head: true })
    .eq("kind", mode)
    .gte("created_at", since);
  if ((count ?? 0) >= LIMITS[mode]) return json({ error: "daily_limit" }, 429);

  parts.push({ text: prompt(mode, lang, body) });
  const result = await generate<Record<string, unknown>>(apiKey, models, {
    contents: [{ role: "user", parts }],
    generationConfig: { temperature: 0.2, maxOutputTokens: 4096, responseMimeType: "application/json", responseSchema: SCHEMAS[mode] },
  }, {
    budgetMs: 100_000,
    tag: mode,
    parse: (text) => {
      const v = JSON.parse(text);
      return v && typeof v === "object" ? (v as Record<string, unknown>) : null;
    },
  });
  if (!result.ok) return json({ error: result.error }, 502);
  const parsed = result.value;

  await supabase.from("ai_usage").insert({ kind: mode });

  // ---- Post-processing / sanity checks ----
  if (mode === "food_photo") {
    const items = (Array.isArray(parsed.items) ? parsed.items : []).slice(0, 12).map((raw) => {
      const it = raw as Record<string, unknown>;
      const g = Math.min(Math.max(num(it.grams), 1), 3000);
      const per = fixPer100(num(it.protein) * 100 / g, num(it.carbs) * 100 / g, num(it.fat) * 100 / g, num(it.kcal) * 100 / g);
      return {
        name: String(it.name ?? "").slice(0, 80),
        grams: r1(g),
        kcal: r1(per.kcal * g / 100),
        protein: r1(per.protein * g / 100),
        carbs: r1(per.carbs * g / 100),
        fat: r1(per.fat * g / 100),
      };
    });
    return json({
      is_food: parsed.is_food !== false,
      dish_name: String(parsed.dish_name ?? "").slice(0, 100),
      items,
      confidence: parsed.confidence ?? "medium",
      analysis: String(parsed.analysis ?? "").slice(0, 800),
      suggestions: (Array.isArray(parsed.suggestions) ? parsed.suggestions : []).slice(0, 4).map((s) => String(s).slice(0, 200)),
    });
  }
  if (mode === "label") {
    const per = fixPer100(num(parsed.protein_per_100g), num(parsed.carbs_per_100g), num(parsed.fat_per_100g), num(parsed.kcal_per_100g));
    return json({
      product_name: String(parsed.product_name ?? "").slice(0, 120),
      brand: String(parsed.brand ?? "").slice(0, 60),
      read_from_label: parsed.read_from_label === true,
      per100g: { ...per, fiber: r1(num(parsed.fiber_per_100g)) },
      serving_g: r1(Math.min(num(parsed.serving_g) || 100, 2000)),
      confidence: parsed.confidence ?? "medium",
      notes: String(parsed.notes ?? "").slice(0, 300),
    });
  }
  return json({
    comparable: parsed.comparable !== false,
    summary: String(parsed.summary ?? "").slice(0, 1200),
    progress_score: Math.min(Math.max(num(parsed.progress_score), 0), 10),
    muscle_gain: parsed.muscle_gain ?? "unclear",
    fat_change: parsed.fat_change ?? "unclear",
    areas: (Array.isArray(parsed.areas) ? parsed.areas : []).slice(0, 8),
    tips: (Array.isArray(parsed.tips) ? parsed.tips : []).slice(0, 8).map((s) => String(s).slice(0, 300)),
    photo_tips: String(parsed.photo_tips ?? "").slice(0, 400),
  });
});
