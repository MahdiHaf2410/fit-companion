-- Shared cache: one YouTube lookup per exercise name, reused by every user.
create table public.exercise_videos (
  query text primary key check (char_length(query) between 2 and 120),
  videos jsonb not null default '[]'::jsonb,   -- [{id, title, channel}], best first
  created_at timestamptz not null default now()
);
alter table public.exercise_videos enable row level security;
-- Anyone using the app (even without an account) can read the cache; only the Edge Function (service role) writes.
create policy "read cached videos" on public.exercise_videos for select to anon, authenticated using (true);

alter table public.ai_usage drop constraint ai_usage_kind_check;
alter table public.ai_usage add constraint ai_usage_kind_check check (kind = any (array['food_macros','food_photo','label','progress','weekly_report','program','meal_plan','voice_log','video']));
