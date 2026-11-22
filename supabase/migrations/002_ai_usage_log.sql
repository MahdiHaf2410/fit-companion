-- Counts AI food-analysis calls per user (daily limit protects the free Gemini quota).
create table public.ai_usage (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade default auth.uid(),
  kind text not null check (kind in ('food_macros')),
  created_at timestamptz not null default now()
);
create index ai_usage_user_created_idx on public.ai_usage (user_id, created_at desc);
alter table public.ai_usage enable row level security;
create policy "own usage select" on public.ai_usage for select to authenticated using ((select auth.uid()) = user_id);
create policy "own usage insert" on public.ai_usage for insert to authenticated with check ((select auth.uid()) = user_id);
