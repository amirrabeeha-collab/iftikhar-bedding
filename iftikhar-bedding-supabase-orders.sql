-- Run once in Supabase Dashboard > SQL Editor.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  customer_email text not null,
  customer_phone text not null,
  delivery_address text not null,
  items jsonb not null check (jsonb_typeof(items) = 'array'),
  total_quantity integer not null check (total_quantity > 0),
  total_price numeric(12, 2) not null check (total_price >= 0),
  status text not null default 'Pending'
    check (status in ('Pending', 'Confirmed', 'Preparing', 'Delivered', 'Cancelled')),
  created_at timestamptz not null default now()
);

alter table public.orders enable row level security;

-- Public website visitors may submit orders but cannot read or edit orders.
drop policy if exists "Public can submit pending orders" on public.orders;
create policy "Public can submit pending orders"
on public.orders
for insert
to anon, authenticated
with check (
  status = 'Pending'
  and total_quantity > 0
  and total_price >= 0
);

grant insert on table public.orders to anon, authenticated;
