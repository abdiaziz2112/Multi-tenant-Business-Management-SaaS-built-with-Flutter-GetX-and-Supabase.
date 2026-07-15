-- ============================================================================
-- 00002_tables.sql — Every table with its columns, CHECK constraints and FKs.
-- No indexes (00003), functions (00004), triggers (00005), views (00006),
-- or policies (00007) here: one responsibility per file.
-- Docs: docs/DATABASE.md (design & WHY) + docs/MIGRATIONS.md §00002
-- ============================================================================

-- ---------------------------------------------------------------------------
-- TENANCY & IDENTITY
-- ---------------------------------------------------------------------------
create table businesses (
  id                      uuid primary key default gen_random_uuid(),
  name                    text not null,
  owner_name              text not null,
  email                   text not null,
  phone                   text not null,                       -- E.164: +2526...
  business_type           text not null,
  country                 text not null,
  status                  text not null default 'pending'
                          check (status in ('pending','approved','rejected','suspended')),
  rejection_reason        text,
  resubmission_count      int  not null default 0,             -- BR-11: max 3
  logo_url                text,
  brand_color             text,
  description             text,
  receipt_footer          text,
  invoice_logo_url        text,
  business_phone          text,
  business_email          text,
  address                 text,
  default_language        text not null default 'en' check (default_language in ('en','so','ar')),
  currency                text not null default 'USD',
  timezone                text not null default 'Africa/Mogadishu',
  session_timeout_seconds int  not null default 300
                          check (session_timeout_seconds between 30 and 600),
  setup_completed         boolean not null default false,
  created_at              timestamptz not null default now(),
  updated_at              timestamptz not null default now(),
  deleted_at              timestamptz
);

create table branches (
  id                 uuid primary key default gen_random_uuid(),
  business_id        uuid not null references businesses(id),
  name               text not null,
  address            text,
  location           geography(point,4326),
  geofence_radius_m  int  not null default 100 check (geofence_radius_m between 10 and 5000),
  is_default         boolean not null default false,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  deleted_at         timestamptz
);

-- profiles.id IS auth.users.id (same UUID). Supabase Auth owns credentials;
-- this table owns app-level user data.
create table profiles (
  id                uuid primary key references auth.users(id) on delete cascade,
  business_id       uuid references businesses(id),  -- NULL only for platform owner
  is_platform_owner boolean not null default false,
  full_name         text,
  phone             text,
  avatar_url        text,
  is_active         boolean not null default true,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create table permissions (
  id          uuid primary key default gen_random_uuid(),
  code        text not null unique,      -- e.g. 'sales.create'
  module      text not null,
  description text
);

create table roles (
  id          uuid primary key default gen_random_uuid(),
  business_id uuid references businesses(id),  -- NULL = system role shared by all
  name        text not null,
  description text,
  created_at  timestamptz not null default now()
);

create table role_permissions (
  role_id       uuid not null references roles(id) on delete cascade,
  permission_id uuid not null references permissions(id) on delete cascade,
  primary key (role_id, permission_id)
);

create table user_roles (
  id         uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id) on delete cascade,
  role_id    uuid not null references roles(id) on delete cascade,
  branch_id  uuid references branches(id)   -- NULL = all branches
);

create table devices (
  id                 uuid primary key default gen_random_uuid(),
  profile_id         uuid not null references profiles(id) on delete cascade,
  device_fingerprint text not null,
  device_name        text,
  is_trusted         boolean not null default false,
  last_seen_at       timestamptz not null default now(),
  created_at         timestamptz not null default now(),
  unique (profile_id, device_fingerprint)
);

create table audit_logs (
  id          uuid primary key default gen_random_uuid(),
  business_id uuid references businesses(id),  -- NULL for platform-level events
  actor_id    uuid references profiles(id),
  action      text not null,
  entity      text not null,
  entity_id   uuid,
  before      jsonb,
  after       jsonb,
  ip          text,
  device_id   uuid references devices(id),
  created_at  timestamptz not null default now()
);

create table invoice_counters (
  business_id uuid primary key references businesses(id),
  last_number int not null default 0
);

-- ---------------------------------------------------------------------------
-- CATALOG & INVENTORY
-- ---------------------------------------------------------------------------
create table categories (
  id          uuid primary key default gen_random_uuid(),
  business_id uuid not null references businesses(id),
  parent_id   uuid references categories(id),
  name        text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

create table brands (
  id          uuid primary key default gen_random_uuid(),
  business_id uuid not null references businesses(id),
  name        text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

create table suppliers (
  id          uuid primary key default gen_random_uuid(),
  business_id uuid not null references businesses(id),
  name        text not null,
  phone       text,
  email       text,
  notes       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

create table products (
  id            uuid primary key default gen_random_uuid(),
  business_id   uuid not null references businesses(id),
  category_id   uuid references categories(id),
  brand_id      uuid references brands(id),
  supplier_id   uuid references suppliers(id),
  name          text not null,
  sku           text,
  barcode       text,
  cost_price    numeric(14,2) not null default 0 check (cost_price >= 0),
  sell_price    numeric(14,2) not null default 0 check (sell_price >= 0),
  tax_rate      numeric(5,2)  not null default 0 check (tax_rate between 0 and 100),
  reorder_level int           not null default 0,
  image_url     text,
  is_active     boolean not null default true,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz
);

create table branch_stock (
  branch_id  uuid not null references branches(id),
  product_id uuid not null references products(id),
  quantity   int  not null default 0 check (quantity >= 0),  -- BR-5: no overselling
  updated_at timestamptz not null default now(),
  primary key (branch_id, product_id)
);

create table stock_movements (
  id             uuid primary key default gen_random_uuid(),
  business_id    uuid not null references businesses(id),
  branch_id      uuid not null references branches(id),
  product_id     uuid not null references products(id),
  type           text not null check (type in
                 ('sale','return','transfer_in','transfer_out','adjustment','purchase')),
  quantity_delta int not null check (quantity_delta <> 0),  -- negative = stock out
  reference_id   uuid,
  actor_id       uuid references profiles(id),
  note           text,
  created_at     timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- SALES, PAYMENTS & CREDIT
-- ---------------------------------------------------------------------------
create table customers (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references businesses(id),
  name         text not null,
  phone        text,
  email        text,
  tags         text[] not null default '{}',
  notes        text,
  credit_limit numeric(14,2) check (credit_limit >= 0),  -- NULL = no credit (BR-14)
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  deleted_at   timestamptz
);

create table sales (
  id             uuid primary key default gen_random_uuid(),
  business_id    uuid not null references businesses(id),
  branch_id      uuid not null references branches(id),
  cashier_id     uuid not null references profiles(id),
  customer_id    uuid references customers(id),
  invoice_number text not null,
  subtotal       numeric(14,2) not null check (subtotal >= 0),
  discount       numeric(14,2) not null default 0 check (discount >= 0),
  tax            numeric(14,2) not null default 0 check (tax >= 0),
  total          numeric(14,2) not null check (total >= 0),
  payment_status text not null default 'unpaid'
                 check (payment_status in ('paid','partial','unpaid')),
  due_date       date,
  status         text not null default 'completed'
                 check (status in ('completed','partially_returned','returned')),
  created_at     timestamptz not null default now(),
  constraint credit_needs_customer check (payment_status = 'paid' or customer_id is not null),
  constraint credit_needs_due_date check (payment_status = 'paid' or due_date is not null)
);

create table sale_items (
  id                uuid primary key default gen_random_uuid(),
  sale_id           uuid not null references sales(id) on delete cascade,
  product_id        uuid not null references products(id),
  quantity          int  not null check (quantity > 0),
  unit_price        numeric(14,2) not null check (unit_price >= 0), -- copied at sale time
  discount          numeric(14,2) not null default 0,
  tax               numeric(14,2) not null default 0,
  line_total        numeric(14,2) not null check (line_total >= 0),
  returned_quantity int not null default 0
                    check (returned_quantity >= 0 and returned_quantity <= quantity)
);

-- ⭐ Append-only money ledger. Immutability = no UPDATE/DELETE policies (00007).
create table payments (
  id                  uuid primary key default gen_random_uuid(),
  business_id         uuid not null references businesses(id),
  sale_id             uuid references sales(id),
  customer_id         uuid references customers(id),
  amount              numeric(14,2) not null check (amount <> 0),
  method              text not null check (method in ('cash','evc','edahab','zaad','bank','other')),
  is_reversal         boolean not null default false,
  reverses_payment_id uuid references payments(id),
  reason              text,
  received_by         uuid not null references profiles(id),
  received_at         timestamptz not null default now(),
  created_at          timestamptz not null default now(),
  constraint payment_has_target   check (sale_id is not null or customer_id is not null),
  constraint reversal_is_negative check
    ((is_reversal and amount < 0 and reverses_payment_id is not null and reason is not null)
     or (not is_reversal and amount > 0))
);

create table returns (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references businesses(id),
  sale_id      uuid not null references sales(id),
  processed_by uuid not null references profiles(id),
  reason       text,
  total        numeric(14,2) not null check (total >= 0),
  created_at   timestamptz not null default now()
);

create table return_items (
  id           uuid primary key default gen_random_uuid(),
  return_id    uuid not null references returns(id) on delete cascade,
  sale_item_id uuid not null references sale_items(id),
  quantity     int  not null check (quantity > 0),
  amount       numeric(14,2) not null check (amount >= 0)
);

create table expenses (
  id          uuid primary key default gen_random_uuid(),
  business_id uuid not null references businesses(id),
  branch_id   uuid not null references branches(id),
  category    text not null,
  amount      numeric(14,2) not null check (amount > 0),
  note        text,
  created_by  uuid not null references profiles(id),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz
);

-- ---------------------------------------------------------------------------
-- WORKFORCE
-- ---------------------------------------------------------------------------
create table employee_invitations (
  id             uuid primary key default gen_random_uuid(),
  business_id    uuid not null references businesses(id),
  email_or_phone text not null,
  role_id        uuid not null references roles(id),
  branch_id      uuid not null references branches(id),
  token          text not null unique default encode(gen_random_bytes(24),'hex'),
  status         text not null default 'pending'
                 check (status in ('pending','accepted','expired','revoked')),
  expires_at     timestamptz not null default now() + interval '7 days',
  created_at     timestamptz not null default now()
);

create table attendance (
  id                   uuid primary key default gen_random_uuid(),
  business_id          uuid not null references businesses(id),
  branch_id            uuid not null references branches(id),
  profile_id           uuid not null references profiles(id),
  clock_in_at          timestamptz not null default now(),
  clock_in_location    geography(point,4326) not null,
  clock_in_accuracy_m  numeric(6,1),
  clock_out_at         timestamptz,
  clock_out_location   geography(point,4326),
  clock_out_accuracy_m numeric(6,1),
  device_id            uuid references devices(id),
  network_type         text,
  battery_level        int check (battery_level between 0 and 100),
  is_mock_location     boolean not null default false,
  status               text not null default 'open' check (status in ('open','closed','flagged')),
  worked_minutes       int generated always as
    (case when clock_out_at is null then null
          else (extract(epoch from (clock_out_at - clock_in_at))/60)::int end) stored,
  created_at           timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- PLATFORM
-- ---------------------------------------------------------------------------
create table subscription_plans (
  id            uuid primary key default gen_random_uuid(),
  name          text not null unique,
  price_monthly numeric(14,2) not null,
  limits        jsonb not null default '{}',
  is_active     boolean not null default true
);

-- Directive: no payment gateway; mock trial on approval; Platform Owner can
-- manually activate / suspend / extend / expire. Statuses reflect that.
create table business_subscriptions (
  id                 uuid primary key default gen_random_uuid(),
  business_id        uuid not null references businesses(id),
  plan_id            uuid not null references subscription_plans(id),
  status             text not null default 'trial'
                     check (status in ('trial','active','suspended','expired','canceled')),
  starts_at          date not null default current_date,
  current_period_end date,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

create table feature_flags (
  key                  text primary key,
  is_enabled           boolean not null default false,
  enabled_business_ids uuid[],           -- NULL = global
  updated_at           timestamptz not null default now()
);

create table announcements (
  id         uuid primary key default gen_random_uuid(),
  title      text not null,
  body       text not null,
  audience   text not null default 'all',
  starts_at  timestamptz not null default now(),
  ends_at    timestamptz,
  created_at timestamptz not null default now()
);

create table platform_settings (
  key        text primary key,
  value      jsonb not null,
  updated_at timestamptz not null default now()
);

create table support_tickets (
  id          uuid primary key default gen_random_uuid(),
  business_id uuid not null references businesses(id),
  created_by  uuid not null references profiles(id),
  subject     text not null,
  body        text not null,
  status      text not null default 'open' check (status in ('open','in_progress','resolved')),
  messages    jsonb not null default '[]',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table notifications (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references businesses(id),
  recipient_id uuid references profiles(id),  -- NULL = everyone in the business
  type         text not null,
  title        text not null,
  body         text not null,
  data         jsonb not null default '{}',
  read_at      timestamptz,
  created_at   timestamptz not null default now()
);
