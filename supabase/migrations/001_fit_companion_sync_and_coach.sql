-- One JSON snapshot of the app's local database per user (cloud backup / sync).
create table public.user_backups (
  user_id uuid primary key references auth.users (id) on delete cascade,
  data jsonb not null,
  schema_version int not null default 3,
  device text,
  updated_at timestamptz not null default now()
);

-- AI coach conversation history (data stays in Supabase).
create table public.coach_messages (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade default auth.uid(),
  role text not null check (role in ('user', 'model')),
  content text not null check (char_length(content) <= 8000),
  created_at timestamptz not null default now()
);
create index coach_messages_user_created_idx on public.coach_messages (user_id, created_at desc);

alter table public.user_backups enable row level security;
alter table public.coach_messages enable row level security;

create policy "own backup select" on public.user_backups for select to authenticated using ((select auth.uid()) = user_id);
create policy "own backup insert" on public.user_backups for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "own backup update" on public.user_backups for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "own backup delete" on public.user_backups for delete to authenticated using ((select auth.uid()) = user_id);

create policy "own messages select" on public.coach_messages for select to authenticated using ((select auth.uid()) = user_id);
create policy "own messages insert" on public.coach_messages for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "own messages delete" on public.coach_messages for delete to authenticated using ((select auth.uid()) = user_id);
