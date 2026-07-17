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
| CR-6 | 2026-07 | AUTH-007: OTP-only verification + trusted-device/biometric model + device management | FRs A14–A17, devices table evolution, 5 device functions, SEC-11..13 | Approved (directive) |
| CR-7 | 2026-07 | Migration 00012 review revisions (U1–U5) + self-review fixes (F1 audit forgery, F2 default-branch race) | 00012 only; tests 6–9 added | Approved (this review) |
| CR-8 | 2026-07 | Phase B directive: third app platform_app + package-name mapping resolved to single new `auth` package; sub-phase plan B1–B6 | packages/auth created (B1); apps wired B2+ | Approved with mapping (this message) |
| CR-8 | 2026-07 | Phase B spec: third app (platform_app) added; package names mapped to approved structure (ui->ui_kit, models/repos->domain/data, networking/services->core); new shared packages/auth justified by 3-app reuse | apps/, packages/auth | Approved (directive + mapping per conflict rule) |
