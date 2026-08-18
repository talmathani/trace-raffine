-- ============================================================
-- TRACÉ RAFINÉ
-- Initial Database Schema
-- ============================================================

create extension if not exists "pgcrypto";

-- ============================================================
-- ENUMS
-- ============================================================

do $$
begin
  create type public.user_role as enum ('customer', 'designer', 'admin');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.design_status as enum ('draft', 'pending', 'published', 'rejected', 'archived');
exception
  when duplicate_object then null;
end $$;

do $$
begin
  create type public.order_status as enum (
    'pending',
    'approved',
    'processing',
    'completed',
    'cancelled',
    'rejected'
  );
exception
  when duplicate_object then null;
end $$;

-- ============================================================
-- PROFILES
-- ============================================================

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role public.user_role not null default 'customer',
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_profiles_role
on public.profiles(role);

-- ============================================================
-- CATEGORIES
-- ============================================================

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name_ar text not null,
  name_en text not null,
  slug text not null unique,
  icon_key text,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists idx_categories_active_sort
on public.categories(is_active, sort_order);

-- ============================================================
-- DESIGNS
-- ============================================================

create table if not exists public.designs (
  id uuid primary key default gen_random_uuid(),

  designer_id uuid not null
    references public.profiles(id)
    on delete restrict,

  category_id uuid
    references public.categories(id)
    on delete set null,

  title_ar text not null,
  title_en text,

  description_ar text,
  description_en text,

  price numeric(12,2) not null default 0
    check (price >= 0),

  currency text not null default 'USD',

  status public.design_status not null default 'draft',

  -- Image shown to users.
  -- This is a STORAGE KEY, not a public URL.
  preview_storage_key text not null,

  -- Original embroidery production file.
  -- Private and never exposed through catalog queries.
  design_storage_key text not null,

  preview_width integer,
  preview_height integer,

  file_extension text,
  file_size_bytes bigint,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  published_at timestamptz
);

create index if not exists idx_designs_designer
on public.designs(designer_id);

create index if not exists idx_designs_category
on public.designs(category_id);

create index if not exists idx_designs_status
on public.designs(status);

create index if not exists idx_designs_published
on public.designs(status, published_at desc);

-- ============================================================
-- ORDERS
-- ============================================================

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),

  customer_id uuid not null
    references public.profiles(id)
    on delete restrict,

  status public.order_status not null default 'pending',

  total_amount numeric(12,2) not null default 0
    check (total_amount >= 0),

  currency text not null default 'USD',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_orders_customer
on public.orders(customer_id);

create index if not exists idx_orders_status
on public.orders(status);

-- ============================================================
-- ORDER ITEMS
-- ============================================================

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),

  order_id uuid not null
    references public.orders(id)
    on delete cascade,

  design_id uuid not null
    references public.designs(id)
    on delete restrict,

  unit_price numeric(12,2) not null
    check (unit_price >= 0),

  created_at timestamptz not null default now(),

  unique(order_id, design_id)
);

create index if not exists idx_order_items_order
on public.order_items(order_id);

create index if not exists idx_order_items_design
on public.order_items(design_id);

-- ============================================================
-- DOWNLOAD ACCESS
-- ============================================================

create table if not exists public.downloads (
  id uuid primary key default gen_random_uuid(),

  customer_id uuid not null
    references public.profiles(id)
    on delete restrict,

  design_id uuid not null
    references public.designs(id)
    on delete restrict,

  order_id uuid not null
    references public.orders(id)
    on delete restrict,

  download_count integer not null default 0
    check (download_count >= 0),

  expires_at timestamptz,

  created_at timestamptz not null default now(),
  last_downloaded_at timestamptz,

  unique(customer_id, design_id, order_id)
);

create index if not exists idx_downloads_customer
on public.downloads(customer_id);

create index if not exists idx_downloads_design
on public.downloads(design_id);

-- ============================================================
-- CUSTOMER CATALOG VIEW
-- IMPORTANT:
-- designer_id is intentionally NOT exposed.
-- design_storage_key is intentionally NOT exposed.
-- ============================================================

create or replace view public.design_catalog
with (security_invoker = true)
as
select
  d.id,
  d.category_id,
  d.title_ar,
  d.title_en,
  d.description_ar,
  d.description_en,
  d.price,
  d.currency,
  d.preview_storage_key,
  d.preview_width,
  d.preview_height,
  d.file_extension,
  d.created_at,
  d.published_at
from public.designs d
where d.status = 'published';

-- ============================================================
-- RLS
-- ============================================================

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.designs enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.downloads enable row level security;

-- ============================================================
-- PROFILES POLICIES
-- ============================================================

drop policy if exists profiles_select_own on public.profiles;

create policy profiles_select_own
on public.profiles
for select
to authenticated
using (
  id = (select auth.uid())
);

drop policy if exists profiles_update_own on public.profiles;

create policy profiles_update_own
on public.profiles
for update
to authenticated
using (
  id = (select auth.uid())
)
with check (
  id = (select auth.uid())
);

-- ============================================================
-- CATEGORY POLICIES
-- ============================================================

drop policy if exists categories_public_read on public.categories;

create policy categories_public_read
on public.categories
for select
to anon, authenticated
using (
  is_active = true
);

-- ============================================================
-- DESIGN POLICIES
-- ============================================================

-- Designers can see their own designs.
drop policy if exists designs_designer_select_own on public.designs;

create policy designs_designer_select_own
on public.designs
for select
to authenticated
using (
  designer_id = (select auth.uid())
);

-- Designers can create designs only for themselves.
drop policy if exists designs_designer_insert_own on public.designs;

create policy designs_designer_insert_own
on public.designs
for insert
to authenticated
with check (
  designer_id = (select auth.uid())
  and exists (
    select 1
    from public.profiles p
    where p.id = (select auth.uid())
      and p.role = 'designer'
  )
);

-- Designers can update only their own designs.
drop policy if exists designs_designer_update_own on public.designs;

create policy designs_designer_update_own
on public.designs
for update
to authenticated
using (
  designer_id = (select auth.uid())
)
with check (
  designer_id = (select auth.uid())
);

-- Designers can delete only their own unpublished designs.
drop policy if exists designs_designer_delete_own on public.designs;

create policy designs_designer_delete_own
on public.designs
for delete
to authenticated
using (
  designer_id = (select auth.uid())
  and status <> 'published'
);

-- ============================================================
-- CUSTOMER CATALOG
-- ============================================================

-- Customers read the VIEW, not the sensitive design table.
grant select on public.design_catalog to anon, authenticated;

-- ============================================================
-- ORDERS
-- ============================================================

drop policy if exists orders_customer_select_own on public.orders;

create policy orders_customer_select_own
on public.orders
for select
to authenticated
using (
  customer_id = (select auth.uid())
);

drop policy if exists orders_customer_insert_own on public.orders;

create policy orders_customer_insert_own
on public.orders
for insert
to authenticated
with check (
  customer_id = (select auth.uid())
  and exists (
    select 1
    from public.profiles p
    where p.id = (select auth.uid())
      and p.role = 'customer'
  )
);

-- ============================================================
-- ORDER ITEMS
-- ============================================================

drop policy if exists order_items_customer_select_own on public.order_items;

create policy order_items_customer_select_own
on public.order_items
for select
to authenticated
using (
  exists (
    select 1
    from public.orders o
    where o.id = order_items.order_id
      and o.customer_id = (select auth.uid())
  )
);

-- ============================================================
-- DOWNLOADS
-- ============================================================

drop policy if exists downloads_customer_select_own on public.downloads;

create policy downloads_customer_select_own
on public.downloads
for select
to authenticated
using (
  customer_id = (select auth.uid())
);


-- ============================================================
-- STORAGE
-- ============================================================

-- Private bucket for designer design files.
-- The bucket itself is managed separately in Supabase Storage.
--
-- Required object path:
--   <designerId>/<designId>/design.ext
--   <designerId>/<designId>/embroidery.ext
--
-- The first path segment MUST equal auth.uid().

drop policy if exists designer_designs_insert_own on storage.objects;

create policy designer_designs_insert_own
on storage.objects
for insert
to authenticated
with check (
    bucket_id = 'designer_designs'
    and (storage.foldername(name))[1] = (select auth.uid())::text
    and exists (
        select 1
        from public.profiles p
        where p.id = (select auth.uid())
        and p.role = 'designer'
    )
);

drop policy if exists designer_designs_select_own on storage.objects;

create policy designer_designs_select_own
on storage.objects
for select
to authenticated
using (
    bucket_id = 'designer_designs'
    and (storage.foldername(name))[1] = (select auth.uid())::text
);

drop policy if exists designer_designs_delete_own on storage.objects;

create policy designer_designs_delete_own
on storage.objects
for delete
to authenticated
using (
    bucket_id = 'designer_designs'
    and (storage.foldername(name))[1] = (select auth.uid())::text
);

-- ============================================================
-- UPDATED_AT TRIGGER
-- ============================================================

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;

create trigger profiles_set_updated_at
before update on public.profiles
for each row
execute function public.set_updated_at();

drop trigger if exists designs_set_updated_at on public.designs;

create trigger designs_set_updated_at
before update on public.designs
for each row
execute function public.set_updated_at();

drop trigger if exists orders_set_updated_at on public.orders;

create trigger orders_set_updated_at
before update on public.orders
for each row
execute function public.set_updated_at();

-- ============================================================
-- INITIAL CATEGORIES
-- ============================================================

insert into public.categories
  (name_ar, name_en, slug, icon_key, sort_order)
values
  ('فساتين السهرة والهوت كوتور', 'Evening & Haute Couture', 'evening-haute-couture', 'checkroom', 1),
  ('تصاميم الساري الهندي', 'Indian Saree Designs', 'indian-saree', 'auto_awesome', 2),
  ('العبايات والبوالطوهات', 'Abayas & Coats', 'abayas-coats', 'layers', 3),
  ('الجلابيات والمخاور', 'Jalabiyas & Makhawer', 'jalabiyas-makhawer', 'pattern', 4),
  ('تصاميم موزعة', 'Distributed Designs', 'distributed', 'scatter_plot', 5),
  ('تصاميم الحواشي', 'Border Designs', 'borders', 'border_style', 6),
  ('الشعارات واللوغوهات', 'Logos & Branding', 'logos', 'diamond', 7),
  ('جديد الأسبوع', 'New This Week', 'new-this-week', 'auto_awesome_mosaic', 8)
on conflict (slug) do nothing;

