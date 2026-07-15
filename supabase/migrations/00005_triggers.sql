-- ============================================================================
-- 00005_triggers.sql — Every trigger. Functions they call live in 00004.
-- Docs: docs/MIGRATIONS.md §00005
-- ============================================================================

-- updated_at maintenance (every table that has the column)
create trigger trg_businesses_updated  before update on businesses
  for each row execute function set_updated_at();
create trigger trg_branches_updated    before update on branches
  for each row execute function set_updated_at();
create trigger trg_profiles_updated    before update on profiles
  for each row execute function set_updated_at();
create trigger trg_categories_updated  before update on categories
  for each row execute function set_updated_at();
create trigger trg_brands_updated      before update on brands
  for each row execute function set_updated_at();
create trigger trg_suppliers_updated   before update on suppliers
  for each row execute function set_updated_at();
create trigger trg_products_updated    before update on products
  for each row execute function set_updated_at();
create trigger trg_stock_updated       before update on branch_stock
  for each row execute function set_updated_at();
create trigger trg_customers_updated   before update on customers
  for each row execute function set_updated_at();
create trigger trg_expenses_updated    before update on expenses
  for each row execute function set_updated_at();
create trigger trg_bsubs_updated       before update on business_subscriptions
  for each row execute function set_updated_at();
create trigger trg_tickets_updated     before update on support_tickets
  for each row execute function set_updated_at();

-- Auto-create profile on signup (trigger lives on Supabase's auth schema).
create trigger trg_on_auth_user_created after insert on auth.users
  for each row execute function handle_new_user();

-- BR-2: never soft-delete the last branch.
create trigger trg_protect_last_branch
  before update of deleted_at on branches
  for each row when (new.deleted_at is not null)
  execute function protect_last_branch();

-- Money & credit rules
create trigger trg_payment_refresh     after insert on payments
  for each row execute function on_payment_insert();
create trigger trg_sales_credit_limit  before insert on sales
  for each row execute function enforce_credit_limit();

-- Mock trial subscription on approval (directive).
create trigger trg_grant_trial after update of status on businesses
  for each row execute function grant_trial_subscription();

-- Audit trail on sensitive tables
create trigger trg_products_audit after insert or update or delete on products
  for each row execute function audit_row_change();
create trigger trg_sales_audit    after insert or update on sales
  for each row execute function audit_row_change();
create trigger trg_payments_audit after insert on payments
  for each row execute function audit_row_change();
create trigger trg_user_roles_audit after insert or update or delete on user_roles
  for each row execute function audit_row_change();
create trigger trg_businesses_audit after update on businesses
  for each row execute function audit_row_change();
