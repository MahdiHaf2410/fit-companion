// deno test supabase/functions/_shared/gemini_test.ts
import { generate } from "./gemini.ts";

function ok(text: string) {
  return new Response(JSON.stringify({ candidates: [{ content: { parts: [{ text }] } }] }), { status: 200 });
}
const sleep = (ms: number, signal?: AbortSignal) =>
  new Promise<void>((res, rej) => {
    const t = setTimeout(res, ms);
    signal?.addEventListener("abort", () => { clearTimeout(t); rej(new DOMException("aborted", "AbortError")); });
  });

function mockFetch(plan: Record<string, (body: Record<string, any>, signal?: AbortSignal) => Promise<Response>>) {
  const calls: string[] = [];
  globalThis.fetch = (async (url: string, init: RequestInit) => {
    const model = /models\/([^:]+):/.exec(String(url))![1];
    calls.push(model);
    return plan[model](JSON.parse(String(init.body)), init.signal ?? undefined);
  }) as typeof fetch;
  return calls;
}
const parse = (t: string) => JSON.parse(t);
const assert = (c: boolean, m: string) => { if (!c) throw new Error(m); };

Deno.test("slow first model: the hedge wins with the second model", async () => {
  const calls = mockFetch({
    a: async (_b, s) => { await sleep(5000, s); return ok('{"from":"a"}'); },
    b: async () => { await sleep(50); return ok('{"from":"b"}'); },
  });
  const t0 = Date.now();
  const r = await generate("k", ["a", "b"], { contents: [] }, { budgetMs: 3000, hedgeMs: 100, tag: "t", parse });
  assert(r.ok && (r as any).value.from === "b", "b should win");
  assert(Date.now() - t0 < 1000, "should not wait for a");
  assert(calls.join() === "a,b", "both called");
});

Deno.test("503 moves on immediately, bad JSON is skipped", async () => {
  mockFetch({
    a: async () => new Response("{}", { status: 503 }),
    b: async () => ok("not json"),
    c: async () => ok('{"from":"c"}'),
  });
  const r = await generate("k", ["a", "b", "c"], { contents: [] }, { budgetMs: 3000, hedgeMs: 10_000, tag: "t", parse });
  assert(r.ok && (r as any).value.from === "c", "c should answer");
});

Deno.test("bad key stops at once", async () => {
  const calls = mockFetch({
    a: async () => new Response("API key not valid", { status: 400 }),
    b: async () => ok('{"x":1}'),
  });
  const r = await generate("k", ["a", "b"], { contents: [] }, { budgetMs: 3000, hedgeMs: 10_000, tag: "t", parse });
  assert(!r.ok && (r as any).error === "gemini_key", "gemini_key");
  assert(calls.length === 1, "no second call");
});

Deno.test("thinking config per model, retried without it when rejected", async () => {
  const seen: Record<string, unknown>[] = [];
  mockFetch({
    "gemini-3.8-flash": async (b) => {
      seen.push(b.generationConfig);
      return b.generationConfig.thinkingConfig ? new Response("thinking_level is not supported", { status: 400 }) : ok('{"ok":true}');
    },
  });
  const r = await generate("k", ["gemini-3.8-flash"], { contents: [], generationConfig: { temperature: 0 } }, { budgetMs: 3000, tag: "t", parse });
  assert(r.ok, "should succeed after retry");
  assert((seen[0] as any).thinkingConfig.thinkingLevel === "low", "low thinking for Gemini 3");
  assert(!(seen[1] as any).thinkingConfig, "retry without thinking");
});

Deno.test("all fail: returns the most useful error, within budget", async () => {
  mockFetch({ a: async () => new Response("{}", { status: 429 }), b: async () => new Response("{}", { status: 503 }) });
  const r = await generate("k", ["a", "b"], { contents: [] }, { budgetMs: 3000, hedgeMs: 10_000, tag: "t", parse });
  assert(!r.ok && (r as any).error === "gemini_quota", "quota error kept");
});
