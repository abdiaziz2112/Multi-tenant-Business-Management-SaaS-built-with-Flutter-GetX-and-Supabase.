-- ============================================================================
-- 00007_rls.sql — Row Level Security. Deny-by-default: enabling RLS forbids
-- everything; each policy below is a deliberate grant. Five-layer model is
-- explained in docs/DATABASE.md §6.
-- Docs: docs/MIGRATIONS.md §00007
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. Enable RLS on every table (the deny-by-default switch)
-- ---------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array[
    'businesses','branches','profiles','roles','permissions','role_permissions',
    'user_roles','devices','audit_logs','invoice_counters',
    'categories','brands','suppliers','products','branch_stock','stock_movements',
    'customers','sales','sale_items','payments','returns','return_items','expenses',
    'employee_invitations','attendance',
    'subscription_plans','business_subscriptions','feature_flags','announcements',
    'platform_settings','support_tickets','notifications']
  loop
    execute format('alter table %I enable row level security', t);
  end loop;
end $$;

-- ---------------------------------------------------------------------------
-- 2. Tenant wall (Layer 1) — standard per-business tables
-- ---------------------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array[
    'branches','categories','brands','suppliers','products',
    'customers','expenses','notifications'] loop
    execute format(
      'create policy tenant_all on %I for all
         using (business_id = current_business_id())
         with check (business_id = current_business_id())', t);
  end loop;
end $$;

-- devices has no business_id: it is personal.
create policy devices_own on devices for all
  using (profile_id = auth.uid()) with check (profile_id = auth.uid());

-- profiles: read colleagues; edit only yourself; managers edit employees.
create policy profiles_read on profiles for select
  using (id = auth.uid()
         or (business_id is not null and business_id = current_business_id())
         or is_platform_owner());
create policy profiles_update_self on profiles for update
  using (id = auth.uid()) with check (id = auth.uid());
create policy profiles_manage_employees on profiles for update
  using (business_id = current_business_id() and has_permission('employees.manage'))
  with check (business_id = current_business_id());

-- businesses: INSERT is open (that IS registration; row starts 'pending');
-- owner reads/updates own row; platform owner reads/updates all.
create policy business_register on businesses for insert with check (true);
create policy business_read on businesses for select
  using (id = current_business_id() or is_platform_owner());
create policy business_update_own on businesses for update
  using (id = current_business_id() and has_permission('settings.manage'))
  with check (id = current_business_id());
create policy business_platform_update on businesses for update
  using (is_platform_owner()) with check (is_platform_owner());

-- Authorization tables
create policy perms_read on permissions for select using (true);
create policy roles_read on roles for select
  using (business_id is null or business_id = current_business_id());
create policy roles_write on roles for all
  using (business_id = current_business_id() and has_permission('settings.manage'))
  with check (business_id = current_business_id());
create policy rp_read on role_permissions for select using (true);
create policy ur_read on user_roles for select
  using (profile_id = auth.uid()
         or exists (select 1 from profiles p where p.id = user_roles.profile_id
                      and p.business_id = current_business_id()));
create policy ur_write on user_roles for all
  using (has_permission('employees.manage')
         and exists (select 1 from profiles p where p.id = user_roles.profile_id
                       and p.business_id = current_business_id()))
  with check (exists (select 1 from profiles p where p.id = user_roles.profile_id
                        and p.business_id = current_business_id()));

-- ---------------------------------------------------------------------------
-- 3. Money & inventory (Layers 2 + 4)
-- ---------------------------------------------------------------------------
-- sales: branch-scoped read; permissioned insert; NO user update/delete —
-- status fields change only via SECURITY DEFINER functions.
create policy sales_read on sales for select
  using (business_id = current_business_id()
         and branch_id in (select user_branch_ids()));
create policy sales_insert on sales for insert
  with check (business_id = current_business_id()
              and branch_id in (select user_branch_ids())
              and cashier_id = auth.uid()
              and has_permission('sales.create'));

create policy sale_items_read on sale_items for select
  using (exists (select 1 from sales s where s.id = sale_items.sale_id
                   and s.business_id = current_business_id()));
create policy sale_items_insert on sale_items for insert
  with check (exists (select 1 from sales s where s.id = sale_items.sale_id
                        and s.business_id = current_business_id()));

-- ⭐ payments: SELECT + INSERT only. The ABSENCE of update/delete policies IS
-- the immutability mechanism. Reversals are permissioned inserts.
create policy payments_read on payments for select
  using (business_id = current_business_id());
create policy payments_insert on payments for insert
  with check (business_id = current_business_id()
              and received_by = auth.uid()
              and ((not is_reversal and has_permission('payments.create'))
                   or (is_reversal and has_permission('payments.reverse'))));

-- stock: read for the business; direct writes gated by permission.
create policy stock_read on branch_stock for select
  using (exists (select 1 from branches b where b.id = branch_stock.branch_id
                   and b.business_id = current_business_id()));
create policy stock_write on branch_stock for all
  using (has_permission('stock.adjust')
         and exists (select 1 from branches b where b.id = branch_stock.branch_id
                       and b.business_id = current_business_id()))
  with check (exists (select 1 from branches b where b.id = branch_stock.branch_id
                        and b.business_id = current_business_id()));

-- stock_movements: an insert-only ledger, like payments.
create policy movements_read on stock_movements for select
  using (business_id = current_business_id());
create policy movements_insert on stock_movements for insert
  with check (business_id = current_business_id());

create policy returns_read on returns for select
  using (business_id = current_business_id());
create policy returns_insert on returns for insert
  with check (business_id = current_business_id() and has_permission('sales.return'));
create policy return_items_rw on return_items for all
  using (exists (select 1 from returns r where r.id = return_items.return_id
                   and r.business_id = current_business_id()))
  with check (exists (select 1 from returns r where r.id = return_items.return_id
                        and r.business_id = current_business_id()));

-- audit_logs: insert-only; read by permission or platform owner.
create policy audit_read on audit_logs for select
  using ((business_id = current_business_id() and has_permission('audit.view'))
         or is_platform_owner());
create policy audit_insert on audit_logs for insert with check (true);

-- invoice_counters: no policies at all — only next_invoice_number()
-- (SECURITY DEFINER) touches it. Users cannot read or write it directly.

-- ---------------------------------------------------------------------------
-- 4. Workforce
-- ---------------------------------------------------------------------------
create policy invitations_rw on employee_invitations for all
  using (business_id = current_business_id() and has_permission('employees.manage'))
  with check (business_id = current_business_id());

create policy attendance_read on attendance for select
  using (business_id = current_business_id()
         and (profile_id = auth.uid() or has_permission('attendance.view_all')));
create policy attendance_insert on attendance for insert
  with check (business_id = current_business_id() and profile_id = auth.uid());
create policy attendance_close on attendance for update
  using (business_id = current_business_id()
         and (profile_id = auth.uid() or has_permission('attendance.view_all')))
  with check (business_id = current_business_id());

-- ---------------------------------------------------------------------------
-- 5. Platform (Layer 5) — platform owner writes; tenants read what's theirs.
-- ---------------------------------------------------------------------------
create policy plans_read  on subscription_plans for select using (true);
create policy plans_write on subscription_plans for all
  using (is_platform_owner()) with check (is_platform_owner());

create policy bsubs_read on business_subscriptions for select
  using (business_id = current_business_id() or is_platform_owner());
create policy bsubs_write on business_subscriptions for all
  using (is_platform_owner()) with check (is_platform_owner());

create policy flags_read  on feature_flags for select using (true);
create policy flags_write on feature_flags for all
  using (is_platform_owner()) with check (is_platform_owner());

create policy ann_read  on announcements for select using (true);
create policy ann_write on announcements for all
  using (is_platform_owner()) with check (is_platform_owner());

create policy psettings_read  on platform_settings for select using (true);
create policy psettings_write on platform_settings for all
  using (is_platform_owner()) with check (is_platform_owner());

create policy tickets_own on support_tickets for all
  using (business_id = current_business_id() or is_platform_owner())
  with check (business_id = current_business_id() or is_platform_owner());
