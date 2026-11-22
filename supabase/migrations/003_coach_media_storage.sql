-- Media (photos/videos) sent to the AI coach. Private bucket, one folder per user.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('coach-media', 'coach-media', false, 41943040,
        array['image/jpeg','image/png','image/webp','image/heic','video/mp4','video/quicktime','video/3gpp','video/webm'])
on conflict (id) do nothing;

create policy "coach media: read own" on storage.objects for select to authenticated
  using (bucket_id = 'coach-media' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "coach media: upload own" on storage.objects for insert to authenticated
  with check (bucket_id = 'coach-media' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "coach media: delete own" on storage.objects for delete to authenticated
  using (bucket_id = 'coach-media' and (storage.foldername(name))[1] = (select auth.uid())::text);

alter table public.coach_messages add column media_path text;
alter table public.coach_messages add column media_type text check (media_type in ('image', 'video'));

alter table public.ai_usage drop constraint ai_usage_kind_check;
alter table public.ai_usage add constraint ai_usage_kind_check check (kind in ('food_macros', 'food_photo', 'label', 'progress'));
