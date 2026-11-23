// Fit Companion: estimates calories & macros of a user-described food with Gemini.
// Uses the same secrets as ai-coach (GEMINI_API_KEY, optional GEMINI_MODEL).
// verify_jwt is OFF because user tokens are ES256; we authenticate with auth.getUser().
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { generate, modelList } from "./gemini.ts";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
const DAILY_LIMIT = 80;

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });
}

const num = (v: unknown) => (typeof v === "number" && isFinite(v) && v >= 0 ? v : 0);
const r1 = (v: number) => Math.round(v * 10) / 10;

const schema = {
  type: "OBJECT",
  properties: {
    food_name: { type: "STRING", description: "Short clean name of the food in the user's language" },
    kcal_per_100g: { type: "NUMBER" },
    protein_per_100g: { type: "NUMBER" },
    carbs_per_100g: { type: "NUMBER" },
    fat_per_100g: { type: "NUMBER" },
    fiber_per_100g: { type: "NUMBER" },
    confidence: { type: "STRING", enum: ["high", "medium", "low"] },
    assumptions: { type: "STRING", description: "1-2 short sentences: what was assumed (cooked/raw, oil, recipe)" },
  },
  required: ["food_name", "kcal_per_100g", "protein_per_100g", "carbs_per_100g", "fat_per_100g", "confidence", "assumptions"],
};

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

  let body: { name?: string; description?: string; grams?: number; language?: string };
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_json" }, 400);
  }
  const name = (body.name ?? "").toString().trim().slice(0, 200);
  const description = (body.description ?? "").toString().trim().slice(0, 1500);
  const grams = Number(body.grams);
  const language = body.language === "ar" ? "ar" : "en";
  if (!name) return json({ error: "empty_name" }, 400);
  if (!isFinite(grams) || grams <= 0 || grams > 5000) return json({ error: "bad_grams" }, 400);

  const since = new Date(Date.now() - 24 * 3600 * 1000).toISOString();
  const { count } = await supabase.from("ai_usage").select("id", { count: "exact", head: true }).gte("created_at", since);
  if ((count ?? 0) >= DAILY_LIMIT) return json({ error: "daily_limit" }, 429);

  const prompt = [
    "You are an expert dietitian and food-composition analyst.",
    "Estimate the nutrition PER 100 g of the food AS DESCRIBED (as eaten: cooked/prepared state, including cooking oil, sauces and listed ingredients).",
    "Base values on reference food-composition tables (USDA FoodData Central, CIQUAL, and Maghreb/Algerian food tables for local dishes such as couscous, chorba, rechta, chakhchoukha, mhajeb, kesra, loubia, garantita, bourek).",
    "If several ingredients are listed with quantities, compute a weighted recipe average per 100 g. If the description gives no details, assume the most common home-made Algerian preparation and say so.",
    "Values must be physically consistent: protein+carbs+fat+fiber <= 100 g per 100 g, and kcal ≈ 4*protein + 4*carbs + 9*fat.",
    `Write food_name and assumptions in ${language === "ar" ? "Arabic" : "English"}.`,
    "",
    `Food: ${name}`,
    `Description: ${description || "(none)"}`,
    `Portion weight: ${grams} g (only for context; return per-100 g values).`,
  ].join("\n");

  const result = await generate<Record<string, unknown>>(apiKey, models, {
    contents: [{ role: "user", parts: [{ text: prompt }] }],
    generationConfig: { temperature: 0.1, maxOutputTokens: 2048, responseMimeType: "application/json", responseSchema: schema },
  }, {
    budgetMs: 50_000,
    tag: "food_macros",
    parse: (text) => {
      const v = JSON.parse(text);
      return v && typeof v === "object" ? (v as Record<string, unknown>) : null;
    },
  });
  if (!result.ok) return json({ error: result.error }, 502);
  const parsed = result.value;

  // ---- Sanity checks so the numbers are always physically consistent ----
  let protein = num(parsed.protein_per_100g);
  let carbs = num(parsed.carbs_per_100g);
  let fat = num(parsed.fat_per_100g);
  let fiber = num(parsed.fiber_per_100g);
  const mass = protein + carbs + fat + fiber;
  if (mass > 100) {
    const k = 100 / mass;
    protein *= k; carbs *= k; fat *= k; fiber *= k;
  }
  const atwater = 4 * protein + 4 * carbs + 9 * fat;
  let kcal = num(parsed.kcal_per_100g);
  let adjusted = false;
  if (kcal <= 0 || Math.abs(kcal - atwater) / Math.max(atwater, 1) > 0.15) {
    kcal = atwater;
    adjusted = true;
  }
  const per100 = { kcal: r1(kcal), protein: r1(protein), carbs: r1(carbs), fat: r1(fat), fiber: r1(fiber) };
  const f = grams / 100;

  await supabase.from("ai_usage").insert({ kind: "food_macros" });

  return json({
    food_name: String(parsed.food_name ?? name).slice(0, 120),
    per100g: per100,
    total: { grams, kcal: r1(per100.kcal * f), protein: r1(per100.protein * f), carbs: r1(per100.carbs * f), fat: r1(per100.fat * f), fiber: r1(per100.fiber * f) },
    confidence: ["high", "medium", "low"].includes(String(parsed.confidence)) ? parsed.confidence : "medium",
    assumptions: String(parsed.assumptions ?? "").slice(0, 400),
    kcal_adjusted: adjusted,
  });
});
