// Fit Companion: finds an embeddable YouTube demo video for an exercise.
// Results are cached in public.exercise_videos (one lookup per exercise name, shared by everyone),
// so the free YouTube Data API quota (10,000 units/day, 100 per search) is used only once per exercise.
// Secrets: YOUTUBE_API_KEY (required). verify_jwt is OFF (ES256 user tokens); we authenticate with auth.getUser().
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
const DAILY_LIMIT = 60; // new (uncached) lookups per user per day

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { ...cors, "Content-Type": "application/json" } });
}
const decode = (s: string) =>
  s.replace(/&#39;/g, "'").replace(/&quot;/g, '"').replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">");

/** Same normalisation as the app: lower-case, single spaces. */
const normalize = (s: string) => s.toLowerCase().replace(/\s+/g, " ").trim().slice(0, 80);

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.startsWith("Bearer ")) return json({ error: "unauthorized" }, 401);
  const url = Deno.env.get("SUPABASE_URL")!;
  const userClient = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, { global: { headers: { Authorization: authHeader } } });
  const { data: userData, error: userError } = await userClient.auth.getUser(authHeader.slice(7));
  if (userError || !userData.user) return json({ error: "unauthorized" }, 401);
  const admin = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_json" }, 400);
  }
  const query = normalize(String(body.name ?? ""));
  if (query.length < 2) return json({ error: "bad_name" }, 400);

  const { data: cached } = await admin.from("exercise_videos").select("videos").eq("query", query).maybeSingle();
  if (cached && Array.isArray(cached.videos) && cached.videos.length > 0) return json({ query, videos: cached.videos });

  const key = Deno.env.get("YOUTUBE_API_KEY");
  if (!key) return json({ error: "missing_youtube_key" }, 503);

  const since = new Date(Date.now() - 24 * 3600 * 1000).toISOString();
  const { count } = await userClient.from("ai_usage").select("id", { count: "exact", head: true }).eq("kind", "video").gte("created_at", since);
  if ((count ?? 0) >= DAILY_LIMIT) return json({ error: "daily_limit" }, 429);

  const params = new URLSearchParams({
    part: "snippet",
    type: "video",
    videoEmbeddable: "true",
    videoSyndicated: "true",
    safeSearch: "strict",
    relevanceLanguage: "en",
    maxResults: "6",
    q: `${query} exercise proper form`,
    key,
  });
  const res = await fetch(`https://www.googleapis.com/youtube/v3/search?${params}`);
  if (!res.ok) {
    const detail = await res.text();
    console.error("youtube_error", res.status, detail.slice(0, 300));
    return json({ error: res.status === 403 && /quota/i.test(detail) ? "youtube_quota" : (res.status === 400 || res.status === 403 ? "youtube_key" : "youtube_error") }, 502);
  }
  const out = await res.json();
  const videos = (Array.isArray(out?.items) ? out.items : [])
    .filter((i: Record<string, any>) => typeof i?.id?.videoId === "string")
    .map((i: Record<string, any>) => ({
      id: String(i.id.videoId),
      title: decode(String(i.snippet?.title ?? "")).slice(0, 140),
      channel: decode(String(i.snippet?.channelTitle ?? "")).slice(0, 80),
    }));
  await userClient.from("ai_usage").insert({ kind: "video" });
  if (videos.length === 0) return json({ query, videos: [] });
  await admin.from("exercise_videos").upsert({ query, videos });
  return json({ query, videos });
});
