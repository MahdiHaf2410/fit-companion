// Shared Gemini caller for the Fit Companion Edge Functions.
//
// Why: on the free tier the flash models are often overloaded ("503 high demand") or slow. Trying them
// one after another with a fixed timeout made long answers (meal plans, reports) fail although a model
// would have answered. This caller:
//   • hedges: starts the next model if the current one has not answered after `hedgeMs`
//     (at most 2 requests in flight) and keeps the first valid answer, aborting the others;
//   • moves on immediately when a model fails (503, 429, 404, bad JSON…);
//   • asks for less "thinking" (faster): thinkingLevel for Gemini 3, thinkingBudget for 2.5 —
//     never both — and retries once without it if a model rejects the setting;
//   • stops a key/permission problem at once (every model would fail the same way).

export const DEFAULT_MODELS = ["gemini-3.8-flash", "gemini-2.5-flash", "gemini-3.6-flash", "gemini-flash-latest"];

export type GenResult<T> = { ok: true; value: T; model: string } | { ok: false; error: string };

type Attempt<T> = { ok: true; value: T; model: string } | { ok: false; error: string; fatal?: boolean };

function thinkingFor(model: string): Record<string, unknown> | null {
  if (/^gemini-[3-9]/.test(model)) return { thinkingLevel: "low" };
  if (/^gemini-2\.5-flash/.test(model)) return { thinkingBudget: 0 };
  return null; // "-latest" aliases: unknown generation, leave the default
}

export async function generate<T>(
  apiKey: string,
  models: string[],
  request: { contents: unknown; generationConfig?: Record<string, unknown>; systemInstruction?: unknown },
  opts: { budgetMs: number; hedgeMs?: number; tag: string; parse: (text: string) => T | null; fast?: boolean; badRequestError?: string },
): Promise<GenResult<T>> {
  const hedgeMs = opts.hedgeMs ?? 12_000;
  const controllers = new Set<AbortController>();

  async function attempt(model: string, withThinking: boolean): Promise<Attempt<T>> {
    const thinking = opts.fast === false || !withThinking ? null : thinkingFor(model);
    const body = JSON.stringify({
      ...request,
      generationConfig: { ...(request.generationConfig ?? {}), ...(thinking ? { thinkingConfig: thinking } : {}) },
    });
    const ctrl = new AbortController();
    controllers.add(ctrl);
    try {
      const res = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`, {
        method: "POST",
        headers: { "Content-Type": "application/json", "x-goog-api-key": apiKey },
        body,
        signal: ctrl.signal,
      });
      if (!res.ok) {
        const detail = await res.text();
        console.error("gemini_error", opts.tag, model, res.status, detail.slice(0, 300));
        if ((res.status === 400 || res.status === 401 || res.status === 403) && /API key|PERMISSION|api_key/i.test(detail)) {
          return { ok: false, error: "gemini_key", fatal: true };
        }
        if (res.status === 400 && thinking && /thinking/i.test(detail)) return attempt(model, false);
        if (res.status === 400 && opts.badRequestError) return { ok: false, error: opts.badRequestError };
        return { ok: false, error: res.status === 429 ? "gemini_quota" : res.status === 404 ? "gemini_model" : "gemini_busy" };
      }
      const out = await res.json();
      const text = (out?.candidates?.[0]?.content?.parts ?? [])
        .filter((p: { thought?: boolean }) => !p.thought)
        .map((p: { text?: string }) => p.text ?? "")
        .join("");
      let value: T | null = null;
      try {
        value = opts.parse(text);
      } catch {
        value = null;
      }
      if (value === null || value === undefined) {
        console.error("gemini_bad_output", opts.tag, model, String(out?.candidates?.[0]?.finishReason ?? ""), text.slice(0, 120));
        return { ok: false, error: "bad_ai_output" };
      }
      return { ok: true, value, model };
    } catch (e) {
      if (!ctrl.signal.aborted) console.error("gemini_network", opts.tag, model, String(e).slice(0, 200));
      return { ok: false, error: "gemini_busy" };
    } finally {
      controllers.delete(ctrl);
    }
  }

  return await new Promise<GenResult<T>>((resolve) => {
    let next = 0;
    let inFlight = 0;
    let done = false;
    let lastError = "gemini_busy";
    let hedgeTimer: ReturnType<typeof setTimeout> | undefined;

    const finish = (r: GenResult<T>) => {
      if (done) return;
      done = true;
      clearTimeout(hedgeTimer);
      clearTimeout(budgetTimer);
      for (const c of controllers) c.abort();
      resolve(r);
    };
    const budgetTimer = setTimeout(() => finish({ ok: false, error: lastError }), opts.budgetMs);

    const launch = () => {
      if (done) return;
      if (next >= models.length) {
        if (inFlight === 0) finish({ ok: false, error: lastError });
        return;
      }
      const model = models[next++];
      inFlight++;
      clearTimeout(hedgeTimer);
      // If this model is slow, start the next one alongside it (max 2 at a time).
      hedgeTimer = setTimeout(() => { if (inFlight < 2) launch(); }, hedgeMs);
      attempt(model, true).then((r) => {
        inFlight--;
        if (done) return;
        if (r.ok) return finish(r);
        if (r.fatal) return finish({ ok: false, error: r.error });
        if (lastError === "gemini_busy" || r.error !== "gemini_busy") lastError = r.error;
        if (inFlight < 2) launch();
        else if (inFlight === 0 && next >= models.length) finish({ ok: false, error: lastError });
      });
    };
    launch();
  });
}

/** Model list: optional GEMINI_MODEL secret first, then the defaults. */
export function modelList(preferred?: string | null): string[] {
  return [...new Set([...(preferred ? [preferred] : []), ...DEFAULT_MODELS])];
}
