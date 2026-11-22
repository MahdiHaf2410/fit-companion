alter table public.ai_usage drop constraint ai_usage_kind_check;
alter table public.ai_usage add constraint ai_usage_kind_check check (kind = any (array['food_macros','food_photo','label','progress','weekly_report','program','meal_plan','voice_log']));

create table public.friend_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade default auth.uid(),
  display_name text not null default 'Athlete' check (char_length(display_name) <= 40),
  friend_code text not null unique default upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6)),
  level int not null default 1,
  xp int not null default 0,
  week_workouts int not null default 0,
  week_volume_kg double precision not null default 0,
  streak_days int not null default 0,
  updated_at timestamptz not null default now()
);
create table public.friendships (
  user_id uuid not null references auth.users(id) on delete cascade,
  friend_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, friend_id),
  check (user_id <> friend_id)
);
create index friendships_friend_idx on public.friendships(friend_id);
alter table public.friend_profiles enable row level security;
alter table public.friendships enable row level security;

create policy "own or friends profiles" on public.friend_profiles for select to authenticated
  using (user_id = (select auth.uid()) or exists (select 1 from public.friendships f where f.user_id = (select auth.uid()) and f.friend_id = friend_profiles.user_id));
create policy "insert own profile" on public.friend_profiles for insert to authenticated with check (user_id = (select auth.uid()));
create policy "update own profile" on public.friend_profiles for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "delete own profile" on public.friend_profiles for delete to authenticated using (user_id = (select auth.uid()));
create policy "see own friendships" on public.friendships for select to authenticated using (user_id = (select auth.uid()));

-- Adding/removing friends goes through these functions (both directions, by code only).
create or replace function public.add_friend(code text) returns text
language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid(); other uuid; other_name text;
begin
  if me is null then raise exception 'unauthorized'; end if;
  select user_id, display_name into other, other_name from public.friend_profiles where friend_code = upper(trim(code));
  if other is null then raise exception 'code_not_found'; end if;
  if other = me then raise exception 'own_code'; end if;
  insert into public.friendships(user_id, friend_id) values (me, other), (other, me) on conflict do nothing;
  return other_name;
end $$;
create or replace function public.remove_friend(friend uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare me uuid := auth.uid();
begin
  if me is null then raise exception 'unauthorized'; end if;
  delete from public.friendships where (user_id = me and friend_id = friend) or (user_id = friend and friend_id = me);
end $$;
revoke all on function public.add_friend(text) from public, anon;
revoke all on function public.remove_friend(uuid) from public, anon;
grant execute on function public.add_friend(text) to authenticated;
grant execute on function public.remove_friend(uuid) to authenticated;
