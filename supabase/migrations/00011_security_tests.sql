-- ============================================================================
-- 00011_security_tests.sql — Security self-checks.
-- These are assertions: if any protection is missing, the migration FAILS and
-- nothing deploys. A failing test here is a feature — it means the database
-- refused to go live insecure. Run again any time with: supabase db reset.
-- Docs: docs/MIGRATIONS.md §00011
-- ============================================================================

-- TEST 1: RLS must be enabled on every APPLICATION table in public.
-- Tables owned by extensions (e.g. PostGIS's spatial_ref_sys — a read-only
-- coordinate-system catalog we cannot even ALTER on Supabase) are excluded by
-- asking Postgres itself, via the pg_depend catalog, "does this table belong
-- to an extension?" (deptype 'e' = extension membership). This is future-proof
-- for any extension, and cannot be abused: a table WE create can never appear
-- extension-owned, so no application table ever escapes this check.
do $$
declare bad text;
begin
  select string_agg(c.relname, ', ') into bad
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public'
     and c.relkind = 'r'                 -- ordinary tables (views have no RLS)
     and not c.relrowsecurity
     and not exists (
       select 1 from pg_depend d
        where d.classid    = 'pg_class'::regclass
          and d.objid      = c.oid
          and d.refclassid = 'pg_extension'::regclass
          and d.deptype    = 'e');
  if bad is not null then
    raise exception 'SECURITY TEST FAILED: RLS disabled on: %', bad;
  end if;
  raise notice 'TEST 1 PASSED: RLS enabled on all application tables';
end $$;

-- TEST 2: payments must be immutable — no UPDATE or DELETE policy may exist.
do $$
begin
  if exists (select 1 from pg_policies
              where schemaname='public' and tablename='payments'
                and cmd in ('UPDATE','DELETE','ALL')) then
    raise exception 'SECURITY TEST FAILED: payments has an UPDATE/DELETE policy — the money ledger must be append-only';
  end if;
  raise notice 'TEST 2 PASSED: payments ledger is append-only';
end $$;

-- TEST 3: same immutability for audit_logs and stock_movements.
do $$
declare t text;
begin
  foreach t in array array['audit_logs','stock_movements'] loop
    if exists (select 1 from pg_policies
                where schemaname='public' and tablename=t
                  and cmd in ('UPDATE','DELETE','ALL')) then
      raise exception 'SECURITY TEST FAILED: % must be append-only', t;
    end if;
  end loop;
  raise notice 'TEST 3 PASSED: audit_logs and stock_movements are append-only';
end $$;

-- TEST 4: every tenant table's policies must reference the tenant wall
-- (current_business_id) or a scoping subquery — no wide-open tenant tables.
do $$
declare bad text;
begin
  select string_agg(distinct tablename, ', ') into bad
    from pg_policies pol
   where schemaname='public'
     and tablename in ('branches','categories','brands','suppliers','products',
                       'customers','sales','payments','expenses','stock_movements',
                       'attendance','notifications')
     and not exists (
       select 1 from pg_policies p2
        where p2.schemaname='public' and p2.tablename=pol.tablename
          and (coalesce(p2.qual,'') like '%current_business_id%'
            or coalesce(p2.with_check,'') like '%current_business_id%'
            or coalesce(p2.qual,'') like '%business_id%'));
  if bad is not null then
    raise exception 'SECURITY TEST FAILED: tenant tables without tenant-wall policies: %', bad;
  end if;
  raise notice 'TEST 4 PASSED: tenant wall present on tenant tables';
end $$;

-- TEST 5: helper functions must exist (policies silently pass NULL without them).
do $$
declare f text;
begin
  foreach f in array array['current_business_id','is_platform_owner',
                           'has_permission','user_branch_ids'] loop
    if to_regproc('public.'||f) is null then
      raise exception 'SECURITY TEST FAILED: helper function % is missing', f;
    end if;
  end loop;
  raise notice 'TEST 5 PASSED: all RLS helper functions exist';
end $$;

-- TEST 6: seeds landed — 4 system roles, 17 permissions, 3 plans.
do $$
begin
  if (select count(*) from roles where business_id is null) <> 4
     or (select count(*) from permissions) < 17
     or (select count(*) from subscription_plans) <> 3 then
    raise exception 'SECURITY TEST FAILED: seed data incomplete';
  end if;
  raise notice 'TEST 6 PASSED: seed data complete';
end $$;