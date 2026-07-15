-- ============================================================================
-- 00004_functions.sql — Every function. Triggers that call them are in 00005;
-- policies that call them are in 00007.
-- SECURITY DEFINER = runs with owner rights (may read tables the caller can't).
-- STABLE = result may be cached within a statement (cheap inside policies).
-- Docs: docs/MIGRATIONS.md §00004
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. RLS vocabulary — the four functions every policy is written with.
-- ---------------------------------------------------------------------------
create or replace function current_business_id() returns uuid
language sql stable security definer set search_path = public as $$
  select business_id from profiles where id = auth.uid() and is_active;
$$;

create or replace function is_platform_owner() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce(
    (select is_platform_owner from profiles where id = auth.uid() and is_active), false);
$$;

create or replace function has_permission(p_code text) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from user_roles ur
    join role_permissions rp on rp.role_id = ur.role_id
    join permissions p       on p.id = rp.permission_id
    where ur.profile_id = auth.uid() and p.code = p_code);
$$;

create or replace function user_branch_ids() returns setof uuid
language sql stable security definer set search_path = public as $$
  select b.id from branches b
  where b.business_id = current_business_id()
    and (exists (select 1 from user_roles ur
                  where ur.profile_id = auth.uid() and ur.branch_id is null)
      or exists (select 1 from user_roles ur
                  where ur.profile_id = auth.uid() and ur.branch_id = b.id));
$$;

-- ---------------------------------------------------------------------------
-- 2. Housekeeping
-- ---------------------------------------------------------------------------
create or replace function set_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

-- Auto-create a profile row for every new auth signup.
create or replace function handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name',''));
  return new;
end $$;

-- BR-2: a business must always keep at least one branch.
create or replace function protect_last_branch() returns trigger
language plpgsql as $$
begin
  if (select count(*) from branches
      where business_id = old.business_id and deleted_at is null and id <> old.id) = 0 then
    raise exception 'Cannot delete the last branch of a business (BR-2)';
  end if;
  return new;
end $$;

-- Generic audit trail: snapshots whole rows as JSONB (attach per table in 00005).
create or replace function audit_row_change() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into audit_logs (business_id, actor_id, action, entity, entity_id, before, after)
  values (
    (to_jsonb(coalesce(new,old))->>'business_id')::uuid,
    auth.uid(),
    lower(tg_op),
    tg_table_name,
    (to_jsonb(coalesce(new,old))->>'id')::uuid,
    case when tg_op in ('UPDATE','DELETE') then to_jsonb(old) end,
    case when tg_op in ('INSERT','UPDATE') then to_jsonb(new) end);
  return coalesce(new, old);
end $$;

-- ---------------------------------------------------------------------------
-- 3. Business logic
-- ---------------------------------------------------------------------------
-- Race-safe per-business invoice numbers (row lock inside UPDATE).
create or replace function next_invoice_number(p_business uuid) returns text
language plpgsql security definer set search_path = public as $$
declare v int;
begin
  insert into invoice_counters (business_id) values (p_business)
  on conflict (business_id) do nothing;
  update invoice_counters set last_number = last_number + 1
   where business_id = p_business
   returning last_number into v;
  return 'INV-' || lpad(v::text, 6, '0');
end $$;

-- Keep sales.payment_status truthful from the payments ledger.
create or replace function refresh_sale_payment_status(p_sale uuid) returns void
language plpgsql security definer set search_path = public as $$
declare v_total numeric; v_paid numeric;
begin
  select s.total, coalesce(sum(p.amount),0) into v_total, v_paid
    from sales s left join payments p on p.sale_id = s.id
   where s.id = p_sale group by s.total;
  update sales set payment_status =
      case when v_paid >= v_total then 'paid'
           when v_paid > 0        then 'partial'
           else 'unpaid' end
   where id = p_sale;
end $$;

create or replace function on_payment_insert() returns trigger
language plpgsql as $$
begin
  if new.sale_id is not null then perform refresh_sale_payment_status(new.sale_id); end if;
  return new;
end $$;

-- BR-14: credit limit enforced by the database, not the app.
create or replace function enforce_credit_limit() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_limit numeric; v_outstanding numeric;
begin
  if new.payment_status = 'paid' then return new; end if;
  select credit_limit into v_limit from customers where id = new.customer_id;
  if v_limit is null then
    raise exception 'Customer has no credit limit; credit sale not allowed (BR-14)';
  end if;
  select coalesce(sum(s.total),0) - coalesce(sum(pp.paid),0) into v_outstanding
    from sales s
    left join (select sale_id, sum(amount) paid from payments group by sale_id) pp
           on pp.sale_id = s.id
   where s.customer_id = new.customer_id and s.payment_status <> 'paid';
  if coalesce(v_outstanding,0) + new.total > v_limit then
    raise exception 'Credit limit exceeded: outstanding % + new % > limit % (BR-14)',
      v_outstanding, new.total, v_limit;
  end if;
  return new;
end $$;

-- Directive (Subscriptions): every business approved by the Platform Owner
-- automatically receives a 30-day mock trial on the Starter plan. Manual
-- activate/suspend/extend/expire happens in the portal by updating the row.
create or replace function grant_trial_subscription() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.status = 'approved' and old.status is distinct from 'approved'
     and not exists (select 1 from business_subscriptions where business_id = new.id) then
    insert into business_subscriptions (business_id, plan_id, status, current_period_end)
    select new.id, sp.id, 'trial', current_date + 30
      from subscription_plans sp where sp.name = 'Starter';
  end if;
  return new;
end $$;
