-- ============================================================================
-- 00003_indexes.sql — Every index, with its reason.
-- Rule of thumb applied: index every FK (Postgres does NOT do it automatically)
-- and every column a list screen filters or sorts by.
-- Docs: docs/MIGRATIONS.md §00003
-- ============================================================================

-- Tenancy & identity
create unique index businesses_email_uq   on businesses (lower(email));
create index businesses_status_idx        on businesses (status);           -- portal filter
create index branches_business_idx        on branches (business_id);
create index profiles_business_idx        on profiles (business_id);
create unique index roles_name_uq         on roles
  (coalesce(business_id,'00000000-0000-0000-0000-000000000000'::uuid), lower(name));
-- One (user, role, branch-or-all) combination; coalesce() is illegal in a PK,
-- so uniqueness lives here as an expression index instead:
create unique index user_roles_uq         on user_roles
  (profile_id, role_id, coalesce(branch_id,'00000000-0000-0000-0000-000000000000'::uuid));
create index user_roles_profile_idx       on user_roles (profile_id);
create index audit_logs_biz_time_idx      on audit_logs (business_id, created_at desc);

-- Catalog & inventory
create unique index categories_name_uq    on categories (business_id, lower(name)) where deleted_at is null;
create unique index brands_name_uq        on brands     (business_id, lower(name)) where deleted_at is null;
create unique index products_barcode_uq   on products   (business_id, barcode)
  where barcode is not null and deleted_at is null;                          -- POS scan
create index products_name_trgm           on products using gin (name gin_trgm_ops); -- fuzzy search
create index products_category_idx        on products (category_id);
create index products_brand_idx           on products (brand_id);
create index products_supplier_idx        on products (supplier_id);
create index stock_movements_biz_time_idx on stock_movements (business_id, created_at desc);
create index stock_movements_product_idx  on stock_movements (product_id, created_at desc);
create index stock_movements_branch_idx   on stock_movements (branch_id);

-- Sales & credit
create index customers_name_trgm          on customers using gin (name  gin_trgm_ops);
create index customers_phone_trgm         on customers using gin (phone gin_trgm_ops);
create index customers_biz_idx            on customers (business_id);
create unique index sales_invoice_uq      on sales (business_id, invoice_number);
create index sales_biz_time_idx           on sales (business_id, created_at desc);
create index sales_branch_idx             on sales (branch_id);
create index sales_cashier_idx            on sales (cashier_id);
create index sales_customer_idx           on sales (customer_id);
create index sales_unpaid_idx             on sales (business_id, due_date)
  where payment_status <> 'paid';                                            -- overdue scan
create index sale_items_sale_idx          on sale_items (sale_id);
create index sale_items_product_idx       on sale_items (product_id);
create index payments_biz_time_idx        on payments (business_id, created_at desc);
create index payments_sale_idx            on payments (sale_id);
create index payments_customer_idx        on payments (customer_id);
create index returns_sale_idx             on returns (sale_id);
create index return_items_return_idx      on return_items (return_id);
create index expenses_biz_time_idx        on expenses (business_id, created_at desc);
create index expenses_branch_idx          on expenses (branch_id);

-- Workforce
create index invitations_business_idx     on employee_invitations (business_id);
-- BR-6: at most ONE open shift per employee — enforced structurally:
create unique index attendance_one_open_uq on attendance (profile_id) where status = 'open';
create index attendance_biz_time_idx      on attendance (business_id, clock_in_at desc);
create index attendance_profile_idx       on attendance (profile_id, clock_in_at desc);
create index attendance_branch_idx        on attendance (branch_id);

-- Platform
create index bsubs_business_idx           on business_subscriptions (business_id);
create index tickets_business_idx         on support_tickets (business_id);
create index notifications_recipient_idx  on notifications (business_id, recipient_id, created_at desc);
