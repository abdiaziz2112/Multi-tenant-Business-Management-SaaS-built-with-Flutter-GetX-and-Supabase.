# MIGRATIONS.md — What Each Migration Does and Why
Companion to `supabase/migrations/`. Read `docs/DATABASE.md` first for the full design; this file explains each SQL file for a beginner.

**Golden rule:** migrations are append-only history. Once a migration has run on a real database, it is never edited — a change becomes a *new* numbered file (`00012_...`). Editing applied history breaks every environment that already ran it.

## §00001_extensions.sql
Turns on two PostgreSQL superpowers: **PostGIS** (real-earth geography — lets a single function decide "is this employee within 100m of the branch?" server-side, where it can't be faked) and **pg_trgm** (trigram indexes — makes fuzzy text search fast so "search everywhere" doesn't slow down as data grows).

## §00002_tables.sql
All 32 tables: columns, types, CHECK constraints, foreign keys — the *shape* of the data, nothing else. Key ideas baked into the shapes themselves: money is `NUMERIC(14,2)` (exact, unlike floats); statuses are `TEXT + CHECK` (easy to extend, unlike enums); `deleted_at` implements soft delete; `branch_stock.quantity >= 0` makes overselling *physically impossible*; the `payments` constraints force reversals to be negative, reasoned, and linked to the payment they correct.

## §00003_indexes.sql
Every index with its reason in a comment. Two beginner traps it avoids: (1) Postgres does **not** auto-index foreign keys — unindexed FKs cause slow joins and mysterious slow deletes; (2) *partial* unique indexes (`WHERE deleted_at IS NULL`) let a soft-deleted "Electronics" category be recreated, while `attendance_one_open_uq` structurally enforces "one open shift per employee" — no code needed, the index *is* the rule.

## §00004_functions.sql
All logic that lives in the database. Three groups: **RLS vocabulary** (`current_business_id`, `is_platform_owner`, `has_permission`, `user_branch_ids` — the four phrases every security policy is written in), **housekeeping** (auto `updated_at`, auto profile creation on signup, last-branch protection, generic JSONB audit snapshots), and **business logic** (race-safe invoice numbers via a row-locking UPDATE; `refresh_sale_payment_status` which derives paid/partial/unpaid from the ledger so the app can never lie about it; `enforce_credit_limit` implementing BR-14; `grant_trial_subscription` implementing the directive's mock-trial-on-approval).
`SECURITY DEFINER` means "run with the function owner's rights" — necessary so policies can read `profiles` — and is why each of these sets `search_path = public` (a standard hardening step against a known Postgres attack).

## §00005_triggers.sql
Wires functions to events. Reading it top to bottom is reading the database's automatic behavior: every update refreshes `updated_at`; every signup creates a profile; the last branch can't be deleted; every payment refreshes its sale's status; every credit sale passes the limit check; every business approval grants a trial; every change to products/sales/payments/roles/businesses lands in the audit log.

## §00006_views.sql
The "computed truth" layer: `sale_balances`, `customer_balances`, `customer_ledger`. Balances are recalculated from immutable ledgers on every read — they can never be stale or edited. **Critical detail:** `security_invoker = true` on every view. Without it, Postgres views run with their *creator's* rights and would leak data across tenants. This is one of the most common real-world Supabase security bugs; test 4 in 00011 plus this setting defend against it.

## §00007_rls.sql
The security heart. Enabling RLS forbids everything (deny-by-default); each policy is a deliberate grant. The five layers from DATABASE.md §6 appear in order: tenant wall → permission-gated writes → branch scoping → **immutability by omission** (payments/stock_movements/audit_logs get SELECT+INSERT only; the *missing* UPDATE/DELETE policies are the mechanism) → platform-owner scope (you can approve businesses but deliberately cannot read their sales). Note `business_register`'s `with check (true)`: inserting a business *is* registration — the row is born `pending` and useless until you approve it.

## §00008_seed_permissions.sql
The 17-capability catalog. Every hidden button in Flutter and every permission-gated policy references one of these codes — one vocabulary shared by UI and database.

## §00009_seed_roles.sql
The four system roles and their permission wiring — the approved Permission Matrix as data. `business_id NULL` means shared by all businesses; per-business custom roles later require zero app changes.

## §00010_seed_data.sql
Three plans (Starter/Professional/Enterprise) and `maintenance_mode` (off). Per the directive: plans are data only; no gateway, no billing code.

## §00011_security_tests.sql
Assertions that make the deployment *fail* if any protection is missing: RLS on all tables; payments/audit_logs/stock_movements append-only; tenant wall present; helper functions exist; seeds complete. A red test here is the system working — the database refusing to go live insecure. Rerun anytime with `supabase db reset`.

## How to apply (preview — full walkthrough in SUPABASE_SETUP.md)
```bash
supabase init          # once, in the repo root
supabase start         # local Postgres in Docker — experiment safely
supabase db reset      # applies 00001→00011 in order, runs the tests
```
Local first, always. The cloud project receives migrations only after they pass locally.
