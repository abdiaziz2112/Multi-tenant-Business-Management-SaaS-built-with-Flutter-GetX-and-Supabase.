# DATABASE.md — Ganacsi Database Design
**Phase:** 0 (Foundation) · **Status:** Awaiting approval · **Engine:** PostgreSQL 15 (Supabase)

This document explains every table, why it exists, its important columns, relationships, indexes, and security. The runnable SQL lives in `supabase/migrations/`. Read this document first, then the SQL — the SQL will feel obvious afterwards.

---

## 0. Conventions Used Everywhere (read once, applies to all tables)

**Standard columns** — almost every table has these; they are explained here once and not repeated 30 times:

| Column | Type | Why it exists |
|---|---|---|
| `id` | `UUID PK DEFAULT gen_random_uuid()` | UUIDs (random 128-bit ids) instead of 1,2,3… because: (a) they can be generated on the phone before the row reaches the server — essential for future offline mode; (b) they don't leak business intelligence (a competitor seeing invoice id "17" learns you've made 17 sales). |
| `business_id` | `UUID FK → businesses` | The multi-tenancy backbone. Every RLS policy filters on it. |
| `created_at` | `TIMESTAMPTZ DEFAULT now()` | `TIMESTAMPTZ` stores the moment in UTC; the app converts to the business timezone for display. Never store local times — they break the day the phone's clock is wrong. |
| `updated_at` | `TIMESTAMPTZ` | Maintained automatically by a trigger (`set_updated_at`) so no app code can forget it. |
| `deleted_at` | `TIMESTAMPTZ NULL` | Soft delete: `NULL` = alive, a timestamp = deleted. Lists filter `WHERE deleted_at IS NULL`; Restore sets it back to `NULL`. Real deletion never happens from the app. |

**Naming rules:** tables are plural snake_case (`sale_items`), columns snake_case, foreign keys `<thing>_id`, booleans `is_*`, timestamps `*_at`.

**Status columns use `TEXT` + `CHECK` constraints, not Postgres `ENUM` types.** Why: enums are painful to change later (you can add values but never remove or rename without migrations gymnastics). `TEXT CHECK (status IN (...))` gives the same protection and is trivially alterable. This is standard Supabase practice.

**Money is `NUMERIC(14,2)`.** Never `float`/`double` — binary floats cannot represent decimal cents exactly and errors accumulate. Never integers-of-cents either for MVP — `NUMERIC` keeps the SQL readable for a beginner and is exact.

---

## 1. Domain: Tenancy & Identity

### 1.1 `businesses` — the tenant root
One row per registered business. Everything else hangs off it.

| Column | Type | Notes |
|---|---|---|
| `name`, `owner_name`, `email`, `phone` | TEXT | Phone stored in E.164 (`+2526…`) — one canonical format |
| `business_type`, `country` | TEXT | From registration form |
| `status` | TEXT CHECK | `pending → approved / rejected / suspended`. Gate for BR-1: no login into business data unless `approved`. |
| `rejection_reason` | TEXT NULL | Shown to owner on rejection (FR-A4) |
| `resubmission_count` | INT DEFAULT 0 | Enforces BR-11 (max 3 resubmissions) |
| `logo_url`, `brand_color`, `description`, `receipt_footer`, `invoice_logo_url`, `business_phone`, `business_email`, `address` | TEXT | Branding block from your amendments |
| `default_language` | TEXT CHECK (`en/so/ar`) | |
| `currency` | TEXT DEFAULT 'USD' | Single currency per business (approved decision) |
| `timezone` | TEXT DEFAULT 'Africa/Mogadishu' | Gap #3: makes "today's sales" mean the owner's today |
| `session_timeout_seconds` | INT DEFAULT 300, CHECK 30–600 | Your 30s–10min requirement |
| `setup_completed` | BOOL DEFAULT false | Setup wizard gate |

**Indexes:** unique on `lower(email)`; index on `status` (portal filters by it constantly).

### 1.2 `branches`
| Column | Notes |
|---|---|
| `name`, `address` | |
| `location GEOGRAPHY(POINT, 4326)` | PostGIS type storing lat/lng on the real Earth. Lets us compute true metric distance for geofencing with one function: `ST_DWithin(location, employee_point, radius)`. This is *why* we use PostGIS instead of storing two float columns and doing math in Dart — the check runs server-side where it can't be bypassed. |
| `geofence_radius_m INT DEFAULT 100` | Attendance radius |
| `is_default BOOL` | BR-2: the last/default branch can't be deleted (enforced by trigger) |

### 1.3 `profiles` — app-level user data
Supabase Auth owns the private `auth.users` table (passwords, email verification). We never touch it directly. `profiles` mirrors it 1-to-1: `profiles.id` **is** `auth.users.id` (same UUID, FK with `ON DELETE CASCADE`). A trigger on `auth.users` creates the profile row automatically at signup — the app cannot forget to.

| Column | Notes |
|---|---|
| `business_id UUID NULL` | NULL only for you, the Platform Owner |
| `is_platform_owner BOOL DEFAULT false` | Belt-and-suspenders flag; checked by `is_platform_owner()` helper |
| `full_name`, `phone`, `avatar_url` | |
| `is_active BOOL DEFAULT true` | Deactivating an employee kills access without deleting history |

### 1.4 `roles`, `permissions`, `role_permissions`, `user_roles` — the authorization engine
This is the Permission Matrix from planning, as data:

- **`permissions`** — global catalog, seeded once: `sales.create`, `sales.discount`, `sales.return`, `payments.create`, `payments.reverse`, `products.manage`, `stock.adjust`, `customers.manage`, `customers.credit_limit`, `employees.manage`, `attendance.view_all`, `reports.branch`, `reports.business`, `settings.manage`, `expenses.create`, `audit.view` … Each row = one capability.
- **`roles`** — `business_id NULL` for the 4 seeded system roles (Owner, Manager, Cashier, Seller) shared by everyone; a non-NULL `business_id` allows custom roles per business later **without any app update** — that was the design promise.
- **`role_permissions`** — which role has which permission (pure join table).
- **`user_roles`** — which user has which role, and where: `branch_id NULL` = all branches (Owner), a specific branch for Managers/Cashiers/Sellers. This one nullable column is what makes "branch-scoped Manager" work.

The helper `has_permission('sales.create')` walks this chain in SQL and is used inside RLS policies — so even a modified app cannot perform an action its role lacks.

### 1.5 `devices`
One row per (user, physical device): `device_fingerprint`, `device_name`, `is_trusted`, `last_seen_at`. Powers new-device OTP (FR-A7) and appears in attendance anti-spoofing.

### 1.6 `audit_logs` — append-only black box
`business_id NULL` (platform events have none), `actor_id`, `action`, `entity`, `entity_id`, `before JSONB`, `after JSONB`, `ip`, `device_id`. `JSONB` snapshots mean we can audit *any* table without designing audit columns per table. RLS: INSERT and SELECT only — no policy grants UPDATE/DELETE, so history cannot be rewritten. Generic trigger `audit_row_change()` is attached to sensitive tables (products, payments, sales, user_roles, businesses).

### 1.7 `invoice_counters` (Gap #4)
`(business_id PK, last_number INT)`. Function `next_invoice_number(business_id)` does `UPDATE … SET last_number = last_number + 1 RETURNING` — the row lock inside the update makes it race-safe (two cashiers checking out simultaneously can never get the same number). Produces human-friendly `INV-000123` per business, because paper receipts with raw UUIDs look untrustworthy.

---

## 2. Domain: Catalog & Inventory

### 2.1 `categories` (self-referencing `parent_id` for subcategories), `brands`, `suppliers`
Simple per-business reference tables. Unique constraint on `(business_id, lower(name))` *where not soft-deleted* — a partial unique index, so "Electronics" can be recreated after being soft-deleted.

### 2.2 `products`
`category_id`, `brand_id NULL`, `supplier_id NULL`, `name`, `sku`, `barcode`, `cost_price`, `sell_price`, `tax_rate NUMERIC(5,2) DEFAULT 0`, `reorder_level INT DEFAULT 0`, `image_url`, `is_active`.
Cost price lives here so profit = sell − cost is computable per line. `barcode` gets an index — the POS scans against it on every beep. Unique partial index on `(business_id, barcode)`.

### 2.3 `branch_stock` — current quantity per branch
`(branch_id, product_id, quantity INT)` with `UNIQUE(branch_id, product_id)` and `CHECK (quantity >= 0)` — BR-5 (no negative stock) enforced by the database itself: an oversell attempt violates the constraint and the whole sale transaction rolls back automatically. We keep a *current quantity* table (fast reads for POS) **plus** a movements ledger (below) as the truth of history.

### 2.4 `stock_movements` — the inventory ledger
Every change is one immutable row: `branch_id`, `product_id`, `type CHECK (sale|return|transfer_in|transfer_out|adjustment|purchase)`, `quantity_delta INT` (negative = out), `reference_id UUID NULL` (the sale/transfer/return that caused it), `actor_id`, `note`.
**Why both tables?** `branch_stock` answers "how many now?" in O(1); `stock_movements` answers "who changed it, when, why?" — the anti-fraud question. They are kept consistent because every write goes through one SQL function inside one transaction.

---

## 3. Domain: Sales, Payments & Credit (the heart)

### 3.1 `customers`
`name`, `phone` (E.164, indexed for search), `email NULL`, `tags TEXT[]`, `notes`, **`credit_limit NUMERIC(14,2) NULL`** — `NULL` means this customer may not buy on credit at all (BR-14). Setting a limit is permission-gated (`customers.credit_limit`).

### 3.2 `sales` — immutable sale header
| Column | Notes |
|---|---|
| `branch_id`, `cashier_id`, `customer_id NULL` | Anonymous cash sales have no customer; credit sales **must** have one (CHECK constraint) |
| `invoice_number TEXT` | From `next_invoice_number()`; unique per business |
| `subtotal`, `discount`, `tax`, `total` | All NUMERIC(14,2) |
| `payment_status` | TEXT CHECK `paid / partial / unpaid` — maintained by trigger from the payments ledger, never set by the app |
| `due_date DATE NULL` | Required when not fully paid (CHECK) |
| `status` | `completed / partially_returned / returned` |

No UPDATE policy exists for sales (except the trigger-managed status fields via functions). BR-4: corrections are returns, never edits.

### 3.3 `sale_items`
`sale_id`, `product_id`, `quantity`, `unit_price`, `discount`, `tax`, `line_total`. Prices are **copied** from the product at sale time — if the product price changes next week, history must not change with it. This is called *denormalization for immutability* and it is deliberate.

### 3.4 `payments` — the append-only money ledger ⭐
| Column | Notes |
|---|---|
| `sale_id NULL`, `customer_id NULL` | A payment can target one sale (checkout) or just the customer (a collection auto-allocated to oldest unpaid sales — installments, BR: at least one of the two must be set) |
| `amount NUMERIC(14,2)` | Negative allowed **only** for reversal rows |
| `method` | CHECK `cash / evc / edahab / zaad / bank / other` |
| `is_reversal BOOL DEFAULT false`, `reverses_payment_id NULL`, `reason` | BR-15: mistakes are corrected by inserting a reversal, permission `payments.reverse`, Owner only |
| `received_by`, `received_at` | Who took the money, when |

**RLS: INSERT + SELECT only. There is deliberately no UPDATE or DELETE policy.** The API physically cannot modify money history. This single design decision is worth more than any amount of app-side validation.

### 3.5 `returns` + `return_items`
Reference the original sale and items; restock via `stock_movements`; on credit sales reduce outstanding balance before refunding cash (BR-13) — implemented in the `process_return()` function, not in Flutter.

### 3.6 `expenses`
`branch_id`, `category`, `amount`, `note`, `created_by`. Feeds profit reports.

### 3.7 Views (computed truth — Concept 5)
- **`sale_balances`**: per sale, `total − COALESCE(SUM(payments),0) AS outstanding`.
- **`customer_balances`**: per customer, total outstanding + overdue amount.
- **`customer_ledger`**: UNION of sales, payments, returns ordered by time — the CRM "Customer Timeline" is literally `SELECT * FROM customer_ledger WHERE customer_id = ?`.

Views recalculate on every read, so they can never be stale or tampered with.

### 3.8 Credit enforcement (BR-14)
A `BEFORE INSERT` trigger on `sales`: if `payment_status != 'paid'`, verify the customer exists, has a `credit_limit`, and `current_outstanding + new_unpaid_amount ≤ credit_limit`. Raises an exception otherwise — the sale never happens, no matter what the app does.

### 3.9 Overdue detection
`pg_cron` job (daily, business-timezone aware) marks sales past `due_date` with outstanding > 0 and inserts rows into `notifications`.

---

## 4. Domain: Workforce

### 4.1 `employee_invitations`
`email_or_phone`, `role_id`, `branch_id`, `token` (random, unique), `status CHECK (pending/accepted/expired/revoked)`, `expires_at`. Accepting the token links a new auth signup to the business with the pre-chosen role — this is how employees join without ever seeing an open "pick your business" screen.

### 4.2 `attendance`
| Column | Notes |
|---|---|
| `branch_id`, `profile_id` | |
| `clock_in_at`, `clock_in_location GEOGRAPHY(POINT)` | |
| `clock_out_at NULL`, `clock_out_location NULL` | NULL while shift is open |
| `worked_minutes` | GENERATED column: computed by Postgres from the two timestamps — cannot disagree with them |
| `clock_in_accuracy_m`, `clock_out_accuracy_m NUMERIC` | GPS accuracy (BR-17) |
| `device_id FK → devices`, `network_type`, `battery_level` | Your amendment metadata |
| `is_mock_location BOOL` | From Android mock-location detection |
| `status` | `open / closed / flagged` — flagged when accuracy > threshold or mock detected; saved but sent to manager review rather than silently trusted |

Geofence check runs in the `clock_in()` SQL function using `ST_DWithin(branch.location, point, branch.geofence_radius_m)` — server-side, unbypassable. Partial unique index ensures one open record per employee (BR-6).

---

## 5. Domain: Platform (portal tables)

- **`subscription_plans`** (seeded: Starter/Professional/Enterprise; `price_monthly`, `limits JSONB` e.g. max branches/employees) and **`business_subscriptions`** (`business_id`, `plan_id`, `status`, `current_period_end`). Enforcement of limits is post-MVP; the data model exists from day one so history is never lost.
- **`feature_flags`**: `key`, `is_enabled`, `enabled_business_ids UUID[] NULL` (NULL = global). Lets you turn features on for pilot shops only.
- **`announcements`**: `title`, `body`, `audience`, `starts_at`, `ends_at` — shown as banners in the business app.
- **`platform_settings`**: single-row style key/value JSONB — includes `maintenance_mode` (BR-16).
- **`support_tickets`**: `business_id`, `created_by`, `subject`, `body`, `status CHECK (open/in_progress/resolved)`, `messages JSONB[]` kept simple for MVP.
- **`notifications`**: `business_id`, `recipient_id NULL` (NULL = everyone in the business), `type`, `title`, `body`, `data JSONB`, `read_at NULL`. In-app center is source of truth; FCM push is best-effort delivery on top.

All platform tables: writable only by `is_platform_owner()`; readable by businesses where relevant (announcements, flags, own tickets, own subscription).

---

## 6. Security Architecture (RLS)

**Layer 0 — deny by default.** `ALTER TABLE … ENABLE ROW LEVEL SECURITY` on every table. With RLS on and no policy, *nothing* is allowed. Every capability below is an explicit grant.

**Layer 1 — tenant wall.** On every tenant table:
```sql
USING (business_id = current_business_id())
```
`current_business_id()` reads the caller's profile via `auth.uid()` (the verified JWT identity). It is `SECURITY DEFINER` + `STABLE` so it's fast and can't be spoofed. Cross-tenant access is impossible even with a stolen anon key — the anon key is *designed* to be public; RLS is the actual lock. (This is the most misunderstood Supabase concept; SECURITY.md will drill it.)

**Layer 2 — permission checks on writes.** Sensitive INSERT/UPDATE policies additionally require `has_permission('…')`, e.g. creating payments requires `payments.create`; adjusting stock requires `stock.adjust`. The UI hides buttons as a courtesy; the database is the enforcer.

**Layer 3 — branch scoping.** Branch-limited roles get policies that also check the row's `branch_id` is in `user_branch_ids()`.

**Layer 4 — immutability by omission.** `payments`, `stock_movements`, `audit_logs`: INSERT + SELECT policies only. The absence of UPDATE/DELETE policies *is* the immutability mechanism.

**Layer 5 — platform owner.** `is_platform_owner()` grants access to `businesses` (approve/reject), platform tables, and audit logs — and deliberately **nothing else**: you can approve a business but not read its sales. That separation protects your customers *and* protects you (you can honestly tell customers you cannot see their data).

---

## 7. Index Summary (why each exists)
- `(business_id, created_at DESC)` on sales, payments, expenses, stock_movements, audit_logs, notifications → every list screen is "this business, newest first".
- `(business_id, barcode)` unique partial on products → POS scan.
- GIN trigram indexes on `products.name`, `customers.name`, `customers.phone` → the "search everywhere" requirement with fast fuzzy matching (`pg_trgm` extension).
- `(branch_id, product_id)` unique on branch_stock → the POS stock lookup.
- Partial index `attendance(profile_id) WHERE status='open'` → one open shift rule + instant "am I clocked in?" check.
- All FKs indexed (Postgres does not do this automatically — a classic beginner trap that causes slow deletes and joins).

---

## 8. What Is Deliberately NOT in This Schema
Multi-currency, payroll, purchase orders, loyalty points, online store, per-customer messaging — all roadmap. The schema leaves clean extension points (e.g., payments.method list, subscriptions) but carries zero dead weight. YAGNI.

---

## 9. Approval Checklist for This Document
1. Payment methods list: `cash, evc, edahab, zaad, bank, other` — correct for your market?
2. Default geofence radius 100m, GPS accuracy flag threshold 50m — acceptable defaults?
3. Anonymous cash sales allowed (no customer attached) — confirm.
4. Collections auto-allocate to **oldest** unpaid sale first — confirm (this is the standard, but some shops prefer choosing the sale manually; we can support both later).
5. Platform Owner cannot see tenant business data (sales, customers…) — confirm this is what you want commercially.

After approval: migrations are applied, then Phase 0 continues with ARCHITECTURE.md, the monorepo skeleton, CODING_STANDARDS.md, and SUPABASE_SETUP.md.
