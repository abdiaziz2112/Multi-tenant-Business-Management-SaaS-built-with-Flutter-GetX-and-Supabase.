-- ============================================================================
-- 00006_views.sql — Computed truth. Balances are NEVER stored columns; they
-- are recalculated on every read from immutable ledgers, so they can never be
-- stale or tampered with. security_invoker=true makes the view respect the
-- CALLER's RLS (without it, views would leak across tenants!).
-- Docs: docs/MIGRATIONS.md §00006
-- ============================================================================

-- Outstanding amount per sale.
create view sale_balances with (security_invoker = true) as
select s.id as sale_id, s.business_id, s.customer_id, s.total, s.due_date, s.payment_status,
       s.total - coalesce(sum(p.amount),0) as outstanding
  from sales s
  left join payments p on p.sale_id = s.id
 group by s.id;

-- Outstanding + overdue per customer (feeds CRM and credit reports).
create view customer_balances with (security_invoker = true) as
select c.id as customer_id, c.business_id, c.name, c.credit_limit,
       coalesce(sum(sb.outstanding),0) as total_outstanding,
       coalesce(sum(sb.outstanding) filter (where sb.due_date < current_date),0) as overdue_amount
  from customers c
  left join sale_balances sb
         on sb.customer_id = c.id and sb.payment_status <> 'paid'
 group by c.id;

-- Unified per-customer timeline: sales (+), payments (−), returns (−).
-- The CRM "Customer Timeline" screen is literally a SELECT on this view.
create view customer_ledger with (security_invoker = true) as
select business_id, customer_id, 'sale' as entry_type, id as entry_id,
       total as amount, created_at
  from sales where customer_id is not null
union all
select business_id, customer_id, 'payment', id, -amount, created_at
  from payments where customer_id is not null
union all
select r.business_id, s.customer_id, 'return', r.id, -r.total, r.created_at
  from returns r join sales s on s.id = r.sale_id
 where s.customer_id is not null;
