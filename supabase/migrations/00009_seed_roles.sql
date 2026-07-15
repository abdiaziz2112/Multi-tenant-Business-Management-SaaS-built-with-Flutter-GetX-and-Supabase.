-- ============================================================================
-- 00009_seed_roles.sql — The four system roles (business_id NULL = shared by
-- every business) and their permissions. This IS the approved Permission
-- Matrix, as data. Custom per-business roles can be added later with zero
-- app changes — that was the design promise.
-- Docs: docs/PERMISSIONS.md + docs/MIGRATIONS.md §00009
-- ============================================================================
insert into roles (business_id, name, description) values
  (null, 'Owner',   'Full control of the business'),
  (null, 'Manager', 'Runs assigned branch: inventory, staff, reports, POS'),
  (null, 'Cashier', 'POS sales, returns, collections'),
  (null, 'Seller',  'POS sales only');

insert into role_permissions (role_id, permission_id)
select r.id, p.id
  from roles r cross join permissions p
 where r.business_id is null and (
       (r.name = 'Owner')  -- Owner: every permission
    or (r.name = 'Manager' and p.code in
        ('sales.create','sales.discount','sales.return','payments.create',
         'products.manage','stock.adjust','customers.manage','customers.delete',
         'customers.credit_limit','employees.manage','attendance.view_all',
         'expenses.create','reports.branch','audit.view'))
    or (r.name = 'Cashier' and p.code in
        ('sales.create','sales.discount','sales.return','payments.create',
         'customers.manage'))
    or (r.name = 'Seller'  and p.code in
        ('sales.create','customers.manage')));
