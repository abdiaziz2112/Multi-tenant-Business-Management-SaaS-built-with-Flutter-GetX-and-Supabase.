# Feature: Setup Wizard (Gate B.3)
**Purpose:** Approved businesses provide the fields registration deferred, in 4 steps, then `complete_setup()` finishes onboarding.
**Business rules:** approved-only (RPC enforces via hardened wall); phone/business_type/currency/timezone/language/branch-name required — validated client-side per step AND server-side in the RPC (each missing field raises a distinct message mapped to a localized key); wizard is resumable (local draft in GetStorage, cleared on success; the DB's `setup_completed` stays the single truth); finishing twice is harmless (idempotent RPC + one-default-branch index); chosen language applies live via LocaleService.
**Database:** consumes deployed `complete_setup(p_business jsonb, p_branch jsonb)` only — no schema changes.
**Flutter:** `features/setup/` — DraftStore (data), SetupWizardController, SetupWizardScreen; option lists (types/currencies/timezones) are app constants, labels localized.
**Security:** no secrets stored; draft holds only business profile fields.
**Testing:** payload-shape test against the RPC JSON contract; draft resume test.
**Future:** logo upload (deferred, D40); country-aware currency/timezone defaults; per-type onboarding tips.
