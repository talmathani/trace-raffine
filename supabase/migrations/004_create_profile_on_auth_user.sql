-- ============================================================
-- TRACÉ RAFINÉ
-- Migration 004: Create Profile On Auth User
-- Restored from remote migration history.
-- ============================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $function$
begin
  insert into public.profiles (
    id,
    role,
    display_name
  )
  values (
    new.id,
    'customer'::public.user_role,
    coalesce(
      nullif(trim(new.raw_user_meta_data ->> 'display_name'), ''),
      null
    )
  )
  on conflict (id) do nothing;

  return new;
end;
$function$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_user();
