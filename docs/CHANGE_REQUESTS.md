# CHANGE_REQUESTS.md — Approved Changes to the Approved Plan
A change enters the project only through this file. Format: number, date, request, impact analysis, decision.

| # | Date | Request | Impact | Decision |
|---|---|---|---|---|
| CR-1 | 2026-07 | Reorganize migrations by responsibility (11 files) | Structure only; no schema change | Approved (directive) |
| CR-2 | 2026-07 | Subscriptions: mock trial on approval; manual Platform Owner control; no gateway | +statuses on business_subscriptions, +trigger | Approved (directive) |

(Empty rows are good. A short file means a focused project.)
| CR-3 | 2026-07 | Configurable per-business payment methods (table-driven, replaces hardcoded CHECK) | New table + trigger validation; payments.method becomes a snapshot code | **PENDING — found as unapproved migration; quarantined to supabase/proposals/; review below** |
| CR-4 | 2026-07 | Per-business GPS accuracy threshold column | One column on businesses | **PENDING — same file** |

**Review of the quarantined proposal (by AI, 2026-07):** Design is sound and consistent with our principles (method stored as an immutable snapshot code, table-driven validation, tenant-walled RLS, settings-gated writes). Two defects block it as-is: (1) **missing backfill** — it seeds payment methods only for *newly approved* businesses; any business approved before this migration would have zero methods and every one of its payments would be rejected by the new validation trigger; (2) **fragile constraint drop** — `drop constraint payments_method_check` assumes Postgres's auto-generated name; must be looked up or use IF EXISTS with verification. Also untested: it was never applied in the local harness. If approved, I will fix both defects, add it as a proper numbered migration, extend the smoke test, and re-run the full suite.
| CR-3 | 2026-07 | Use GetX Translations (+ intl for formatting) instead of Flutter Intl codegen | Localization mechanism only; same 3 languages & RTL | **Pending user approval** — implemented provisionally; trivially reversible |
| CR-4 | 2026-07 | Rebrand all user-facing surfaces to **Hanti ERP** (internal package/repo names unchanged) | Strings, titles, future emails | Approved (directive) |
| CR-5 | 2026-07 | UX rule: never expose implementation details (providers, frameworks, stack traces) to users | Neutral wording, BootstrapErrorApp, Failure mapping | Approved (directive) |
