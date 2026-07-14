-- Run this once in the Supabase dashboard: SQL Editor -> New query -> paste -> Run
-- Project: https://supabase.com/dashboard/project/lnmncvmxrbboyppfxcih

-- 1. Table to store exam metadata
create table if not exists public.exams (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  level text,
  file_path text not null,
  file_name text not null,
  uploaded_at timestamptz not null default now()
);

alter table public.exams enable row level security;

-- Only signed-in users (the shared teacher login) can read or write
create policy "Authenticated read" on public.exams
  for select to authenticated using (true);

create policy "Authenticated insert" on public.exams
  for insert to authenticated with check (true);

create policy "Authenticated delete" on public.exams
  for delete to authenticated using (true);

-- 2. Private storage bucket for the actual files
insert into storage.buckets (id, name, public)
values ('exams', 'exams', false)
on conflict (id) do nothing;

create policy "Authenticated read exams bucket" on storage.objects
  for select to authenticated using (bucket_id = 'exams');

create policy "Authenticated upload exams bucket" on storage.objects
  for insert to authenticated with check (bucket_id = 'exams');

create policy "Authenticated delete exams bucket" on storage.objects
  for delete to authenticated using (bucket_id = 'exams');

-- 3. After running this, create the ONE shared login:
--    Dashboard -> Authentication -> Users -> Add user
--    Set an email (e.g. teachers@lmg-dus.example) and a password all 15 teachers will share.
--    Untick "Auto Confirm User" only if you want to verify email first; for a shared
--    internal account, ticking "Auto Confirm User" is simplest.
