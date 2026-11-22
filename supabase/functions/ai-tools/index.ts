// Fit Companion: AI tools with Gemini.
//   weekly_report : weekly progress report from the user's stats (sent by the app)
//   program       : builds a training program using ONLY exercise ids from the app catalogue
//   meal_plan     : one-day meal plan matching the user's macro targets + shopping list
//   voice_log     : audio → transcript → food items with macros
// Secrets: GEMINI_API_KEY (required), GEMINI_MODEL (optional).
// verify_jwt is OFF (ES256 user tokens); we authenticate with auth.getUser().
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
const LIMITS: Record<string, number> = { weekly_report: 6, program: 10, meal_plan: 12, voice_log: 60 };
const PER_MODEL_TIMEOUT_MS = 40_000;
const TOTAL_BUDGET_MS = 80_000;
const FALLBACK_MODELS = ["gemini-3.8-flash", "gemini-3.6-flash", "gemini-2.5-flash", "gemini-flash-latest"];
const MAX_AUDIO_B64 = 8_000_000; // ~6 MB

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });
}
const num = (v: unknown) => (typeof v === "number" && isFinite(v) && v >= 0 ? v : 0);
const r1 = (v: number) => Math.round(v * 10) / 10;
const str = (v: unknown, max: number) => String(v ?? "").slice(0, max);
const strList = (v: unknown, n: number, max: number) => (Array.isArray(v) ? v : []).slice(0, n).map((s) => str(s, max));

/** Keeps item macros consistent: kcal ≈ 4P+4C+9F and P+C+F <= grams. */
function fixItem(raw: Record<string, unknown>) {
  const g = Math.min(Math.max(num(raw.grams), 1), 3000);
  let p = num(raw.protein), c = num(raw.carbs), f = num(raw.fat);
  const mass = p + c + f;
  if (mass > g) {
    const k = g / mass;
    p *= k; c *= k; f *= k;
  }
  const atwater = 4 * p + 4 * c + 9 * f;
  let kcal = num(raw.kcal);
  if (kcal <= 0 || Math.abs(kcal - atwater) / Math.max(atwater, 1) > 0.15) kcal = atwater;
  return { name: str(raw.name, 80), grams: r1(g), kcal: r1(kcal), protein: r1(p), carbs: r1(c), fat: r1(f) };
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
  weekly_report: {
    type: "OBJECT",
    properties: {
      headline: { type: "STRING" },
      score: { type: "NUMBER", description: "0-10 overall week score" },
      summary: { type: "STRING" },
      wins: { type: "ARRAY", items: { type: "STRING" } },
      improve: { type: "ARRAY", items: { type: "STRING" } },
      next_week: { type: "ARRAY", items: { type: "STRING" } },
    },
    required: ["headline", "score", "summary", "wins", "improve", "next_week"],
  },
  program: {
    type: "OBJECT",
    properties: {
      name: { type: "STRING" },
      description: { type: "STRING" },
      days: {
        type: "ARRAY",
        items: {
          type: "OBJECT",
          properties: {
            name: { type: "STRING" },
            exercises: {
              type: "ARRAY",
              items: {
                type: "OBJECT",
                properties: {
                  exercise_id: { type: "STRING" },
                  sets: { type: "INTEGER" },
                  reps: { type: "INTEGER" },
                  rest_seconds: { type: "INTEGER" },
                },
                required: ["exercise_id", "sets", "reps", "rest_seconds"],
              },
            },
          },
          required: ["name", "exercises"],
        },
      },
      notes: { type: "ARRAY", items: { type: "STRING" } },
    },
    required: ["name", "description", "days", "notes"],
  },
  meal_plan: {
    type: "OBJECT",
    properties: {
      meals: {
        type: "ARRAY",
        items: {
          type: "OBJECT",
          properties: { name: { type: "STRING" }, time: { type: "STRING" }, items: { type: "ARRAY", items: macroItem } },
          required: ["name", "time", "items"],
        },
      },
      shopping_list: { type: "ARRAY", items: { type: "STRING" } },
      tips: { type: "ARRAY", items: { type: "STRING" } },
    },
    required: ["meals", "shopping_list", "tips"],
  },
  voice_log: {
    type: "OBJECT",
    properties: {
      transcript: { type: "STRING" },
      items: { type: "ARRAY", items: macroItem },
    },
    required: ["transcript", "items"],
  },
};

function prompt(mode: string, lang: string, body: Record<string, unknown>): string {
  const L = lang === "ar" ? "Arabic (simple, Algerian-friendly)" : "English";
  const ctx = str(body.context, 6000);
  if (mode === "weekly_report") {
    return [
      "You are a friendly but honest fitness & nutrition coach writing a WEEKLY REPORT for your client.",
      "Base everything ONLY on the data below (training sessions, volume, PRs, calories/protein vs targets, water, weight trend, sleep).",
      "headline: one motivating sentence. score: 0-10. summary: 3-4 sentences.",
      "wins: 2-4 concrete things that went well (with numbers). improve: 1-3 concrete problems. next_week: 3 specific actionable goals.",
      "If data is missing for an area, don't invent it.",
      `Data:\n${ctx}`,
      `Write everything in ${L}.`,
    ].join("\n");
  }
  if (mode === "program") {
    return [
      "You are an expert strength coach. Build a training program for this client.",
      "Use ONLY exercise ids from the catalogue below (format id|name|muscle|equipment). Never invent ids.",
      "Respect the requested number of training days, the available equipment and the goal. Balance muscle groups, put compound lifts first,",
      "4-7 exercises per day, sets 2-5, reps fitting the goal (strength 3-6, hypertrophy 6-12, endurance 12-20), rest 60-180 s.",
      "Day names short (e.g. 'Push', 'Upper A'). notes: 2-4 tips on progression and recovery.",
      `Client: ${ctx}`,
      `Request: ${str(body.request, 600)}`,
      `Catalogue:\n${str(body.catalogue, 40000)}`,
      `Write name, description, day names and notes in ${L}.`,
    ].join("\n");
  }
  if (mode === "meal_plan") {
    return [
      "You are a sports dietitian. Create a realistic ONE-DAY meal plan that hits the client's targets (±5%).",
      "Prefer foods easy to find and cook in Algeria / the Maghreb (e.g. eggs, lentils, chickpeas, chicken, sardines, semolina, msemen in moderation, dates, olive oil, yogurt, vegetables) unless the request says otherwise.",
      "Each item: realistic grams with kcal/protein/carbs/fat FOR THAT WEIGHT (kcal ≈ 4P+4C+9F). 3-6 meals with a time (HH:MM).",
      "shopping_list: grouped ingredient list with total quantities. tips: 2-3 short prep/budget tips.",
      `Targets & client: ${ctx}`,
      `Request: ${str(body.request, 600)}`,
      `Write meal names, item names, list and tips in ${L}.`,
    ].join("\n");
  }
  return [
    "The audio is a person describing what they ate (Arabic, Algerian Darija, French or English, possibly mixed).",
    "transcript: what they said. items: every food/drink they mentioned with realistic grams (use stated quantities, otherwise a typical portion)",
    "and kcal/protein/carbs/fat FOR THAT WEIGHT (kcal ≈ 4P+4C+9F). Know Algerian foods (kesra, chorba, couscous, mhadjeb, garantita, etc.).",
    "If nothing about food is said, return an empty items array.",
    `Write the transcript in the spoken language and item names in ${L}.`,
  ].join("\n");
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);
  const started = Date.now();

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
  const models = [...new Set([...(preferred ? [preferred] : []), ...FALLBACK_MODELS])];

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_json" }, 400);
  }
  const mode = String(body.mode ?? "");
  if (!(mode in SCHEMAS)) return json({ error: "bad_mode" }, 400);
  const lang = body.language === "ar" ? "ar" : "en";

  const parts: Record<string, unknown>[] = [];
  if (mode === "voice_log") {
    const audio = (body.audio ?? {}) as Record<string, unknown>;
    const data = str(audio.data, MAX_AUDIO_B64 + 1);
    const mime = str(audio.mime, 40) || "audio/mp4";
    if (!data || data.length > MAX_AUDIO_B64 || !mime.startsWith("audio/")) return json({ error: "bad_audio" }, 400);
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
  const payload = JSON.stringify({
    contents: [{ role: "user", parts }],
    generationConfig: {
      temperature: mode === "voice_log" ? 0.1 : 0.5,
      maxOutputTokens: 8192,
      responseMimeType: "application/json",
      responseSchema: SCHEMAS[mode],
    },
  });

  let parsed: Record<string, unknown> | null = null;
  let lastError = "gemini_error";
  for (const model of models) {
    const remaining = TOTAL_BUDGET_MS - (Date.now() - started);
    if (remaining < 6_000) {
      lastError = "gemini_busy";
      break;
    }
    const ctrl = new AbortController();
    const timer = setTimeout(() => ctrl.abort(), Math.min(PER_MODEL_TIMEOUT_MS, remaining));
    try {
      const res = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`, {
        method: "POST",
        headers: { "Content-Type": "application/json", "x-goog-api-key": apiKey },
        body: payload,
        signal: ctrl.signal,
      });
      if (!res.ok) {
        const detail = await res.text();
        console.error("gemini_error", mode, model, res.status, detail.slice(0, 300));
        if ((res.status === 400 || res.status === 401 || res.status === 403) && /API key|PERMISSION|api_key/i.test(detail)) {
          return json({ error: "gemini_key" }, 502);
        }
        lastError = res.status === 429 ? "gemini_quota" : res.status === 404 ? "gemini_model" : "gemini_busy";
        continue;
      }
      const out = await res.json();
      const text = (out?.candidates?.[0]?.content?.parts ?? [])
        .filter((p: { thought?: boolean }) => !p.thought)
        .map((p: { text?: string }) => p.text ?? "")
        .join("");
      try {
        parsed = JSON.parse(text);
        break;
      } catch {
        lastError = "bad_ai_output";
      }
    } catch (e) {
      console.error("gemini_timeout_or_network", mode, model, String(e).slice(0, 200));
      lastError = "gemini_busy";
    } finally {
      clearTimeout(timer);
    }
  }
  if (!parsed) return json({ error: lastError }, 502);

  await supabase.from("ai_usage").insert({ kind: mode });

  if (mode === "weekly_report") {
    return json({
      headline: str(parsed.headline, 200),
      score: Math.min(Math.max(num(parsed.score), 0), 10),
      summary: str(parsed.summary, 1200),
      wins: strList(parsed.wins, 5, 300),
      improve: strList(parsed.improve, 4, 300),
      next_week: strList(parsed.next_week, 4, 300),
    });
  }
  if (mode === "program") {
    const allowed = new Set(
      str(body.catalogue, 40000).split("\n").map((l) => l.split("|")[0].trim()).filter((s) => s.length > 0),
    );
    const days = (Array.isArray(parsed.days) ? parsed.days : []).slice(0, 7).map((d) => {
      const day = d as Record<string, unknown>;
      return {
        name: str(day.name, 40),
        exercises: (Array.isArray(day.exercises) ? day.exercises : [])
          .map((e) => e as Record<string, unknown>)
          .filter((e) => allowed.has(str(e.exercise_id, 80)))
          .slice(0, 10)
          .map((e) => ({
            exercise_id: str(e.exercise_id, 80),
            sets: Math.min(Math.max(Math.round(num(e.sets)) || 3, 1), 8),
            reps: Math.min(Math.max(Math.round(num(e.reps)) || 10, 1), 30),
            rest_seconds: Math.min(Math.max(Math.round(num(e.rest_seconds)) || 90, 30), 300),
          })),
      };
    }).filter((d) => d.exercises.length > 0);
    if (days.length === 0) return json({ error: "bad_ai_output" }, 502);
    return json({ name: str(parsed.name, 60), description: str(parsed.description, 400), days, notes: strList(parsed.notes, 5, 300) });
  }
  if (mode === "meal_plan") {
    const meals = (Array.isArray(parsed.meals) ? parsed.meals : []).slice(0, 8).map((m) => {
      const meal = m as Record<string, unknown>;
      return {
        name: str(meal.name, 60),
        time: str(meal.time, 5),
        items: (Array.isArray(meal.items) ? meal.items : []).slice(0, 10).map((i) => fixItem(i as Record<string, unknown>)),
      };
    });
    return json({ meals, shopping_list: strList(parsed.shopping_list, 40, 120), tips: strList(parsed.tips, 4, 300) });
  }
  return json({
    transcript: str(parsed.transcript, 1000),
    items: (Array.isArray(parsed.items) ? parsed.items : []).slice(0, 12).map((i) => fixItem(i as Record<string, unknown>)),
  });
});
