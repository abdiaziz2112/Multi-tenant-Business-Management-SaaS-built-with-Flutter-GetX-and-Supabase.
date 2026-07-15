-- ============================================================================
-- 00010_seed_data.sql — Subscription plans and platform settings.
-- Directive: no payment gateway in MVP. Plans exist as data; the trial trigger
-- (00004/00005) assigns Starter automatically on business approval; the
-- Platform Owner manages statuses manually from the portal.
-- Docs: docs/MIGRATIONS.md §00010
-- ============================================================================
insert into subscription_plans (name, price_monthly, limits) values
  ('Starter',       9.99, '{"max_branches": 1,   "max_employees": 5}'),
  ('Professional', 24.99, '{"max_branches": 3,   "max_employees": 20}'),
  ('Enterprise',   59.99, '{"max_branches": 999, "max_employees": 999}');

insert into platform_settings (key, value) values
  ('maintenance_mode', '{"enabled": false, "message": ""}');
