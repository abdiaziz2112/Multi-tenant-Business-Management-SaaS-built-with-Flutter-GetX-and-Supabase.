# Ganacsi — Retail ERP / POS / CRM SaaS (monorepo)
- `apps/business_app`     Flutter Android/iOS app for business owners & staff
- `apps/platform_portal`  Flutter Web app for the Platform Owner
- `packages/core`         Env config, Supabase client, errors, validators, session
- `packages/localization` en / so / ar translations (GetX)
- `packages/ui_kit`       Theme + reusable widgets (buttons, fields, states)
- `packages/domain`       Entities & repository contracts (pure Dart)
- `packages/data`         Repository implementations (Supabase)
- `supabase/`             Database migrations (applied ✔) and edge functions
- `docs/`                 All project documentation — start with FOUNDATION_SETUP.md
