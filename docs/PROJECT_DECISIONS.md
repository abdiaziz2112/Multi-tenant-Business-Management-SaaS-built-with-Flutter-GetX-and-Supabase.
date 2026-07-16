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
| D16 | 2026-07 | One cloud project (ganacsi-dev) until M7; production project created before pilot | Solo-dev overhead; no users yet |
| D17 | 2026-07 | Migrations validated on clean PostgreSQL 16 + 10-assertion smoke test before first cloud push | Never trust unapplied SQL |
| D16 | 2026-07 | Environment via --dart-define-from-file (compile-time), env/*.json gitignored | Can't forget config in release builds; no runtime file loading |
| D17 | 2026-07 | GetX Translations for i18n (CR-3, pending); flutter_localizations for RTL | Idiomatic with GetX-only rule; no codegen for a beginner |
| D18 | 2026-07 | Portal is English-only and desktop-plain | One user (Platform Owner); clarity over beauty |
| D19 | 2026-07 | Foundation acceptance = live Supabase read of subscription_plans via RLS | Proves env, client, network AND security wiring in one check |
| D20 | 2026-07 | Security Test 1 excludes extension-owned tables via pg_depend (not a name list) | PostGIS's spatial_ref_sys lives in public and cannot be RLS'd; catalog-based exclusion is future-proof and un-abusable |
| D21 | 2026-07 | Migrate to Supabase publishable key (`publishableKey:` param, `SUPABASE_PUBLISHABLE_KEY` env var) | anonKey deprecated; legacy keys sunset end of 2026; one call site made it a 5-minute migration |
| D22 | 2026-07 | All internal packages declare `publish_to: "none"` | Pub treats versioned packages as publishable and forbids path deps; explicit intent fixes it project-wide |
| D23 | 2026-07 | File headers end with `library;` (anchored library doc comments) | Satisfies dangling_library_doc_comments while keeping mandatory documentation |
| D24 | 2026-07 | Brand = Hanti ERP; internal names (packages, repo) unchanged per directive | Rebrands are string-level, not identifier-level — cheap now, cheap later |
| D25 | 2026-07 | Somali via custom So*Localizations delegates (key labels translated, long tail falls back to English) | Flutter ships no Somali Material strings; delegates make Locale('so') legal |
| D26 | 2026-07 | Startup failures show BootstrapErrorApp (friendly, trilingual); real error to console only | Users never see config/stack details; developers keep full truth |
