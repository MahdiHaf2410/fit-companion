// Fit Companion AI coach — proxies Gemini so the API key never ships in the APK.
// Secrets (Dashboard > Edge Functions > Secrets): GEMINI_API_KEY (required), GEMINI_MODEL (optional).
// verify_jwt is OFF on purpose: this project signs user tokens with ES256, and the
// function authenticates every request itself with auth.getUser() (401 otherwise).
// Media: the app uploads a photo/video to the private bucket `coach-media/<uid>/...`
// and sends its path; the function downloads it (as the user) and sends it inline to Gemini.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { generate, modelList } from "./gemini.ts";
import { encodeBase64 } from "jsr:@std/encoding@1/base64";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const DAILY_LIMIT = 40; // protects the free Gemini quota
const MAX_MEDIA_BYTES = 40 * 1024 * 1024;

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });
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
  const userId = userData.user.id;

  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) return json({ error: "missing_gemini_key" }, 503);
  const preferred = Deno.env.get("GEMINI_MODEL");
  const models = modelList(preferred);

  let body: { message?: string; context?: string; language?: string; media?: { path?: string; type?: string; mime?: string } };
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_json" }, 400);
  }
  const message = (body.message ?? "").toString().trim().slice(0, 2000);
  const context = (body.context ?? "").toString().slice(0, 4000);
  const language = body.language === "ar" ? "ar" : "en";
  const media = body.media && body.media.path ? body.media : null;
  if (!message && !media) return json({ error: "empty_message" }, 400);

  const since = new Date(Date.now() - 24 * 3600 * 1000).toISOString();
  const { count } = await supabase
    .from("coach_messages")
    .select("id", { count: "exact", head: true })
    .eq("role", "user")
    .gte("created_at", since);
  if ((count ?? 0) >= DAILY_LIMIT) return json({ error: "daily_limit" }, 429);

  // ---- Optional media (photo / video) from the user's private folder ----
  let mediaPart: Record<string, unknown> | null = null;
  let mediaType: "image" | "video" | null = null;
  if (media) {
    const path = String(media.path);
    if (!path.startsWith(`${userId}/`)) return json({ error: "bad_media" }, 400);
    const { data: blob, error } = await supabase.storage.from("coach-media").download(path);
    if (error || !blob) return json({ error: "media_not_found" }, 400);
    if (blob.size > MAX_MEDIA_BYTES) return json({ error: "media_too_big" }, 400);
    const mime = (media.mime || blob.type || "application/octet-stream").toString();
    mediaType = mime.startsWith("video/") ? "video" : "image";
    mediaPart = { inlineData: { mimeType: mime, data: encodeBase64(new Uint8Array(await blob.arrayBuffer())) } };
  }

  // Order by id (identity, strictly increasing): both rows of one exchange share created_at.
  const { data: history } = await supabase
    .from("coach_messages")
    .select("role, content, media_type")
    .order("id", { ascending: false })
    .limit(12);
  const contents = (history ?? []).reverse().map((m) => ({
    role: m.role,
    parts: [{ text: (m.media_type ? `[${m.media_type} attached] ` : "") + (m.content || "") || "(media)" }],
  }));
  const userParts: Record<string, unknown>[] = [];
  if (mediaPart) userParts.push(mediaPart);
  userParts.push({
    text: message || (language === "ar" ? "حلّل هذا من فضلك." : "Please analyse this."),
  });
  contents.push({ role: "user", parts: userParts as never });

  const system = [
    "You are 'Fit Companion Coach', a friendly, practical gym and nutrition coach inside a fitness app.",
    language === "ar"
      ? "Always answer in Arabic. If the user writes in Algerian Darija, answer in simple Arabic/Darija."
      : "Answer in the user's language (default English).",
    "Be concise (max ~200 words), concrete and evidence-based: give numbers (grams of protein, sets, reps, kg, kcal).",
    "If the user sends a FOOD photo/video: identify the foods, estimate portions and give kcal + protein/carbs/fat, then suggest improvements only if needed.",
    "If the user sends an EXERCISE video/photo: check technique (posture, range of motion, tempo, safety) and give 2-4 precise corrections.",
    "If the user sends a BODY photo: comment only on training progress/physique objectively and respectfully, with actionable advice.",
    "Use the user's data summary below to personalise advice. Never invent data that is not there.",
    "You are not a doctor: for injuries, pain, medical conditions, eating disorders or medication, advise seeing a professional.",
    "Prefer foods common in Algeria/Maghreb when suggesting meals.",
    "USER DATA SUMMARY:\n" + (context || "(no data shared)"),
  ].join("\n");

  const result = await generate<string>(apiKey, models, {
    systemInstruction: { parts: [{ text: system }] },
    contents,
    generationConfig: { temperature: 0.6, maxOutputTokens: 2048 },
  }, {
    budgetMs: 110_000,
    // Videos are big: wait longer before sending a second copy to another model.
    hedgeMs: mediaPart ? 45_000 : 12_000,
    tag: "coach",
    parse: (text) => text.trim() || null,
    badRequestError: mediaPart ? "media_unsupported" : undefined,
  });
  if (!result.ok) return json({ error: result.error === "bad_ai_output" ? "empty_reply" : result.error }, 502);
  const reply = result.value;
  const usedModel = result.model;
  console.log("coach_ok", usedModel, mediaType ?? "text", Date.now() - started, "ms");

  // Insert sequentially so ids keep question-before-answer order.
  await supabase.from("coach_messages").insert({
    user_id: userId,
    role: "user",
    content: message,
    media_path: media ? String(media.path) : null,
    media_type: mediaType,
  });
  await supabase.from("coach_messages").insert({ user_id: userId, role: "model", content: reply.slice(0, 8000) });

  return json({ reply });
});
