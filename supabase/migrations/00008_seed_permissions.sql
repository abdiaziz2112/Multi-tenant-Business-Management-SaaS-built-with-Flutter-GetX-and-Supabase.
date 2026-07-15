-- ============================================================================
-- 00008_seed_permissions.sql — The global permission catalog.
-- Each row = one capability the app can check with has_permission(code).
-- Docs: docs/PERMISSIONS.md + docs/MIGRATIONS.md §00008
-- ============================================================================
insert into permissions (code, module, description) values
  ('sales.create',           'sales',    'Create sales at POS'),
  ('sales.discount',         'sales',    'Apply discounts'),
  ('sales.return',           'sales',    'Process returns/refunds'),
  ('payments.create',        'payments', 'Record customer payments / collections'),
  ('payments.reverse',       'payments', 'Reverse a payment (Owner-level correction)'),
  ('products.manage',        'inventory','Create/edit products, categories, brands, suppliers'),
  ('stock.adjust',           'inventory','Stock adjustments and transfers'),
  ('customers.manage',       'crm',      'Create/edit customers'),
  ('customers.delete',       'crm',      'Soft-delete customers'),
  ('customers.credit_limit', 'crm',      'Set or change customer credit limits'),
  ('employees.manage',       'hr',       'Invite/edit/deactivate employees, assign roles'),
  ('attenAdance.view_all',    'hr',       'View and correct attendance in scope'),
  ('expenses.create',        'finance',  'Record expenses'),
  ('reports.branch',         'reports',  'View branch-level reports'),
  ('reports.business',       'reports',  'View business-wide reports'),
  ('settings.manage',        'settings', 'Edit business settings and branding'),
  ('audit.view',             'security', 'View audit logs');
