-- ============================================================
-- TRACÉ RAFINÉ
-- Migration: Secure Checkout + Admin Approval + Downloads
-- ============================================================

begin;

-- ------------------------------------------------------------
-- 1. Remove unsafe direct customer order creation
-- ------------------------------------------------------------

drop policy if exists orders_customer_insert_own
on public.orders;

-- ------------------------------------------------------------
-- 2. Admin read access
-- ------------------------------------------------------------

drop policy if exists orders_admin_select_all
on public.orders;

create policy orders_admin_select_all
on public.orders
for select
to authenticated
using (
  exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role = 'admin'::public.user_role
  )
);

drop policy if exists order_items_admin_select_all
on public.order_items;

create policy order_items_admin_select_all
on public.order_items
for select
to authenticated
using (
  exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role = 'admin'::public.user_role
  )
);

drop policy if exists downloads_admin_select_all
on public.downloads;

create policy downloads_admin_select_all
on public.downloads
for select
to authenticated
using (
  exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role = 'admin'::public.user_role
  )
);

-- ------------------------------------------------------------
-- 3. Secure Checkout RPC
--
-- Client sends ONLY design IDs.
-- Prices are always read from public.designs.
-- Total is calculated server-side.
-- ------------------------------------------------------------

create or replace function public.create_order_from_cart(
  p_design_ids uuid[]
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_customer_id uuid;
  v_order_id uuid;
  v_total numeric := 0;
  v_count integer;
begin
  v_customer_id := auth.uid();

  if v_customer_id is null then
    raise exception 'Authentication required';
  end if;

  if p_design_ids is null
     or cardinality(p_design_ids) = 0 then
    raise exception 'Cart is empty';
  end if;

  v_count := cardinality(p_design_ids);

  if v_count > 100 then
    raise exception 'Cart exceeds the maximum allowed items';
  end if;

  -- Verify customer profile.
  if not exists (
    select 1
    from public.profiles
    where id = v_customer_id
      and role = 'customer'::public.user_role
  ) then
    raise exception 'Customer profile required';
  end if;

  -- Reject duplicate design IDs.
  if exists (
    select 1
    from (
      select unnest(p_design_ids) as design_id
      group by design_id
      having count(*) > 1
    ) duplicates
  ) then
    raise exception 'Duplicate design in cart';
  end if;

  -- Calculate the real total from the database.
  select coalesce(sum(d.price), 0)
  into v_total
  from public.designs d
  where d.id = any(p_design_ids)
    and d.status = 'published'::public.design_status;

  -- Every requested design must exist and be published.
  if (
    select count(*)
    from public.designs d
    where d.id = any(p_design_ids)
      and d.status = 'published'::public.design_status
  ) <> v_count then
    raise exception 'One or more designs are unavailable';
  end if;

  -- Create the order using the server-calculated total.
  insert into public.orders (
    customer_id,
    status,
    total_amount,
    currency
  )
  values (
    v_customer_id,
    'pending'::public.order_status,
    v_total,
    'USD'
  )
  returning id into v_order_id;

  -- Create one order item per design.
  insert into public.order_items (
    order_id,
    design_id,
    unit_price
  )
  select
    v_order_id,
    d.id,
    d.price
  from public.designs d
  where d.id = any(p_design_ids)
    and d.status = 'published'::public.design_status;

  return v_order_id;
end;
$$;

revoke all
on function public.create_order_from_cart(uuid[])
from public;

grant execute
on function public.create_order_from_cart(uuid[])
to authenticated;

-- ------------------------------------------------------------
-- 4. Secure Admin Order Approval
--
-- Processing:
-- pending
--   -> processing
--   -> create downloads
--   -> completed
--
-- Entire operation is transactional.
-- ------------------------------------------------------------

create or replace function public.approve_order(
  p_order_id uuid
)
returns public.orders
language plpgsql
security definer
set search_path = public
as $$
declare
  v_admin_id uuid;
  v_order public.orders;
begin
  v_admin_id := auth.uid();

  if v_admin_id is null then
    raise exception 'Authentication required';
  end if;

  -- Verify administrator.
  if not exists (
    select 1
    from public.profiles p
    where p.id = v_admin_id
      and p.role = 'admin'::public.user_role
  ) then
    raise exception 'Administrator privileges required';
  end if;

  -- Lock the order during approval.
  select *
  into v_order
  from public.orders
  where id = p_order_id
  for update;

  if not found then
    raise exception 'Order not found';
  end if;

  if v_order.status <> 'pending'::public.order_status then
    raise exception 'Only pending orders can be approved';
  end if;

  -- Move to processing.
  update public.orders
  set status = 'processing'::public.order_status
  where id = p_order_id;

  -- Provision downloads.
  insert into public.downloads (
    customer_id,
    design_id,
    order_id,
    download_count
  )
  select
    v_order.customer_id,
    oi.design_id,
    oi.order_id,
    0
  from public.order_items oi
  where oi.order_id = p_order_id
  on conflict (customer_id, design_id, order_id)
  do nothing;

  -- Make sure the order actually contains items.
  if not exists (
    select 1
    from public.order_items
    where order_id = p_order_id
  ) then
    raise exception 'Order contains no items';
  end if;

  -- Complete after successful provisioning.
  update public.orders
  set status = 'completed'::public.order_status
  where id = p_order_id
  returning * into v_order;

  return v_order;
end;
$$;

revoke all
on function public.approve_order(uuid)
from public;

grant execute
on function public.approve_order(uuid)
to authenticated;

-- ------------------------------------------------------------
-- 5. Secure Admin Order Rejection
-- ------------------------------------------------------------

create or replace function public.reject_order(
  p_order_id uuid
)
returns public.orders
language plpgsql
security definer
set search_path = public
as $$
declare
  v_admin_id uuid;
  v_order public.orders;
begin
  v_admin_id := auth.uid();

  if v_admin_id is null then
    raise exception 'Authentication required';
  end if;

  if not exists (
    select 1
    from public.profiles p
    where p.id = v_admin_id
      and p.role = 'admin'::public.user_role
  ) then
    raise exception 'Administrator privileges required';
  end if;

  select *
  into v_order
  from public.orders
  where id = p_order_id
  for update;

  if not found then
    raise exception 'Order not found';
  end if;

  if v_order.status <> 'pending'::public.order_status then
    raise exception 'Only pending orders can be rejected';
  end if;

  update public.orders
  set status = 'rejected'::public.order_status
  where id = p_order_id
  returning * into v_order;

  return v_order;
end;
$$;

revoke all
on function public.reject_order(uuid)
from public;

grant execute
on function public.reject_order(uuid)
to authenticated;

-- ------------------------------------------------------------
-- 6. Admin profile lookup helper
-- ------------------------------------------------------------

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'admin'::public.user_role
  );
$$;

revoke all
on function public.is_admin()
from public;

grant execute
on function public.is_admin()
to authenticated;

commit;
