-- TRACÉ RAFINÉ
-- Fix profiles read access required by authenticated Storage policies.
-- READ/SECURITY FIX ONLY.

drop policy if exists profiles_select_own on public.profiles;

create policy profiles_select_own
on public.profiles
for select
to authenticated
using (
  id = (select auth.uid())
);

grant select on table public.profiles to authenticated;