# PROJECT_DECISIONS.md — Decision Log
Every significant decision, its date, and its reason. When future-you asks "why did we do it this way?", the answer is here. Append-only.

| # | Date | Decision | Reason |
|---|---|---|---|
| D1 | 2026-07 | Multi-tenancy via `business_id` + RLS (one database) | Operable by a solo dev; standard Supabase SaaS pattern |
| D2 | 2026-07 | Permissions stored as data (roles = permission bundles) | New roles without app updates |
| D3 | 2026-07 | Two apps (mobile business app + Flutter Web portal) in a monorepo with shared packages | Clean security split; shared code fixed once |
| D4 | 2026-07 | Credit: immutable `payments` ledger; balances computed via views, never stored | Fraud-resistance; accounting correctness |
| D5 | 2026-07 | Sales immutable (BR-4); corrections via returns | Anti-fraud; trustworthy history |
| D6 | 2026-07 | Single currency per business for MVP | Dual currency doubles money-path complexity; revisit after pilot |
| D7 | 2026-07 | Money = NUMERIC(14,2), never float | Exact decimal arithmetic |
| D8 | 2026-07 | TEXT + CHECK instead of Postgres ENUM for statuses | Easy to alter later |
| D9 | 2026-07 | Geofence checked server-side with PostGIS | Cannot be bypassed by a modified app |
| D10 | 2026-07 | Immutability by omission: no UPDATE/DELETE policies on payments, stock_movements, audit_logs | The absence of a policy is the strongest lock |
| D11 | 2026-07 | Platform Owner cannot read tenant business data | Customer trust; honest privacy claim |
| D12 | 2026-07 | Migrations organized by responsibility (00001–00011) for initial schema; all future changes are new sequential files | Directive; migrations are append-only history |
| D13 | 2026-07 | Subscriptions: schema + mock trial trigger only; no payment gateway in MVP | Directive |
| D14 | 2026-07 | Views use `security_invoker = true` | Prevents cross-tenant leaks through views |
| D15 | 2026-07 | Thermal receipt printing (ESC/POS) included in POS milestone | Market expectation; painful to retrofit |
