-- TRACÉ RAFINÉ
-- Fix downloads read access required by authenticated Storage policies.
-- READ/SECURITY FIX ONLY.

grant select on table public.downloads to authenticated;

drop policy if exists downloads_select_own on public.downloads;

create policy downloads_select_own
on public.downloads
for select
to authenticated
using (
  customer_id = (select auth.uid())
);