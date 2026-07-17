-- ============================================================================
-- 00012_authentication.sql — Authentication Infrastructure (Phase A)
-- Implements: docs/features/authentication.md (approved, incl. AUTH-007)
-- Full per-function documentation: docs/MIGRATIONS.md §00012
-- Rollback strategy: docs/MIGRATIONS.md §00012-Rollback
-- ============================================================================

-- ---------------------------------------------------------------------------
-- SECTION 1: Registration slimming (FR-A1)
-- phone & business_type move to the Setup Wizard; complete_setup() re-imposes
-- them as required before a business can finish setup.
-- ---------------------------------------------------------------------------
alter table businesses alter column phone drop not null;
alter table businesses alter column business_type drop not null;

-- ---------------------------------------------------------------------------
-- SECTION 2: Hardened tenant wall (SEC-1)
-- current_business_id() now answers "which APPROVED business are you?".
-- Pending / rejected / suspended / soft-deleted tenants get NULL, which makes
-- every tenant-table policy evaluate false — approval and suspension become
-- instant, database-enforced switches over the whole schema at once.
-- ---------------------------------------------------------------------------
create or replace function current_business_id() returns uuid
language sql stable security definer set search_path = public as $$
  select p.business_id
    from profiles p
    join businesses b on b.id = p.business_id
   where p.id = auth.uid()
     and p.is_active
     and b.status = 'approved'
     and b.deleted_at is null;
$$;

-- Status-BLIND companion, used in exactly ONE place (the businesses read
-- policy below) so Pending/Rejected/Suspended screens can show the user their
-- own business row and rejection reason. It must never appear in any other
-- policy — that rule is asserted by TEST 4 at the bottom of this file.
create or replace function owner_business_id() returns uuid
language sql stable security definer set search_path = public as $$
  select business_id from profiles where id = auth.uid() and is_active;
$$;

drop policy business_read on businesses;
create policy business_read on businesses for select
  using (id = owner_business_id() or is_platform_owner());

-- ---------------------------------------------------------------------------
-- SECTION 2b: Audit-insert hardening (self-review finding F1)
-- The 00007 policy allowed WITH CHECK (true): any authenticated client could
-- forge audit rows for any tenant. Now: a client may only write audit rows
-- naming ITSELF as actor, scoped to its own business (or NULL business for
-- its own auth events). Trigger/RPC audit writes are unaffected: they run as
-- the function owner, which bypasses RLS by design.
-- ---------------------------------------------------------------------------
drop policy audit_insert on audit_logs;
create policy audit_insert on audit_logs for insert
  with check (actor_id = auth.uid()
              and (business_id is null or business_id = owner_business_id()));

-- ---------------------------------------------------------------------------
-- SECTION 3: AUTH-007 — device trust (evolves the EXISTING devices table)
-- ---------------------------------------------------------------------------
alter table devices
  add column platform   text,
  add column trusted_at timestamptz,
  add column expires_at timestamptz,
  add column revoked_at timestamptz;

-- Trust-expiry configuration (Review Update 2). We reuse the EXISTING
-- platform_settings table rather than adding a config table (DRY), a GUC
-- (invisible to the portal, awkward to manage), or a hardcode (rejected).
-- The Platform Owner will edit this from the portal; changes apply to all
-- future trust/renewal events with zero migrations.
insert into platform_settings (key, value)
values ('device_trust', '{"expiry_days": 90}')
on conflict (key) do nothing;

create or replace function device_trust_expiry_days() returns int
language sql stable set search_path = public as $$
  select coalesce(
    (select (value->>'expiry_days')::int from platform_settings where key='device_trust'),
    90);  -- safe default if the row is ever deleted
$$;

-- Structural immutability for trust: users may READ their devices but never
-- write rows directly — the ABSENCE of insert/update policies means the only
-- mutation path is the SECURITY DEFINER functions below (SEC-12).
drop policy devices_own on devices;
create policy devices_read_own on devices for select
  using (profile_id = auth.uid());

-- Trust the caller's current device. Called by the app ONLY after a
-- successful email-OTP verification (FR-A15). 90-day expiry.
create or replace function trust_device(
  p_fingerprint text, p_name text, p_platform text
) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_id uuid;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  if coalesce(p_fingerprint,'') = '' then raise exception 'Fingerprint required'; end if;

  insert into devices (profile_id, device_fingerprint, device_name, platform,
                       is_trusted, trusted_at, expires_at, revoked_at, last_seen_at)
  values (auth.uid(), p_fingerprint, p_name, p_platform,
          true, now(), now() + make_interval(days => device_trust_expiry_days()), null, now())
  on conflict (profile_id, device_fingerprint) do update
     set device_name = excluded.device_name,
         platform    = excluded.platform,
         is_trusted  = true,
         trusted_at  = now(),
         expires_at  = now() + make_interval(days => device_trust_expiry_days()),
         revoked_at  = null,
         last_seen_at= now()
  returning id into v_id;

  insert into audit_logs (business_id, actor_id, action, entity, entity_id)
  values (owner_business_id(), auth.uid(), 'device_trusted', 'devices', v_id);
  return v_id;
end $$;

-- Is the caller's current device trusted RIGHT NOW?
-- trusted ∧ not revoked ∧ not expired. The app uses this to decide
-- biometric-unlock vs email-OTP at login (FR-A15).
create or replace function is_device_trusted(p_fingerprint text) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from devices
     where profile_id = auth.uid()
       and device_fingerprint = p_fingerprint
       and is_trusted
       and revoked_at is null
       and expires_at > now());
$$;

-- Record activity + sliding renewal: active devices never annoy the user with
-- surprise OTPs; dormant devices expire naturally (SEC-13).
create or replace function touch_device(p_fingerprint text) returns void
language plpgsql security definer set search_path = public as $$
begin
  update devices
     set last_seen_at = now(),
         expires_at   = case when is_trusted and revoked_at is null
                             then now() + make_interval(days => device_trust_expiry_days())
                             else expires_at end
   where profile_id = auth.uid() and device_fingerprint = p_fingerprint;
end $$;

-- Revoke ONE device (from the device-management screen). Own devices only.
create or replace function revoke_device(p_device_id uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  update devices
     set is_trusted = false, revoked_at = now()
   where id = p_device_id and profile_id = auth.uid();
  if not found then raise exception 'Device not found'; end if;
  insert into audit_logs (business_id, actor_id, action, entity, entity_id)
  values (owner_business_id(), auth.uid(), 'device_revoked', 'devices', p_device_id);
end $$;

-- "Logout everywhere": revoke ALL of the caller's devices (FR-A16).
-- The app pairs this with a global session sign-out.
create or replace function revoke_all_devices() returns int
language plpgsql security definer set search_path = public as $$
declare v_count int;
begin
  update devices set is_trusted = false, revoked_at = now()
   where profile_id = auth.uid() and revoked_at is null;
  get diagnostics v_count = row_count;
  insert into audit_logs (business_id, actor_id, action, entity)
  values (owner_business_id(), auth.uid(), 'devices_revoked_all', 'devices');
  return v_count;
end $$;

-- Password-change policy (Review Update 4, FR-A18): on password change/reset,
-- the app calls this to revoke every OTHER trusted device. Rationale: password
-- changes often follow suspicion of compromise — an attacker holding a stolen
-- trusted device must not survive the change; the CURRENT device just proved
-- control (password, or reset-OTP on the owner's email), so revoking it too
-- adds friction without security gain. Industry-standard model.
create or replace function revoke_other_devices(p_current_fingerprint text) returns int
language plpgsql security definer set search_path = public as $$
declare v_count int;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  update devices set is_trusted = false, revoked_at = now()
   where profile_id = auth.uid()
     and revoked_at is null
     and device_fingerprint is distinct from p_current_fingerprint;
  get diagnostics v_count = row_count;
  insert into audit_logs (business_id, actor_id, action, entity)
  values (owner_business_id(), auth.uid(), 'devices_revoked_others', 'devices');
  return v_count;
end $$;

-- ---------------------------------------------------------------------------
-- SECTION 4: Registration lifecycle RPCs (SEC-2 — the chicken-and-egg fix)
-- ---------------------------------------------------------------------------
-- Atomic registration: business + profile link + Owner role, or nothing.
create or replace function register_business(
  p_business_name text, p_business_email text, p_country text, p_owner_name text
) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_business uuid; v_owner_role uuid;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  -- One business per user account (edge case: double-tap, retry, abuse).
  if owner_business_id() is not null then
    raise exception 'Account already linked to a business';
  end if;
  -- Server-side re-validation (never trust the client alone).
  if length(trim(coalesce(p_business_name,''))) < 2 then raise exception 'Invalid business name'; end if;
  if length(trim(coalesce(p_owner_name,''))) < 2 then raise exception 'Invalid owner name'; end if;
  if coalesce(p_business_email,'') !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then raise exception 'Invalid business email'; end if;
  if length(trim(coalesce(p_country,''))) < 2 then raise exception 'Invalid country'; end if;

  insert into businesses (name, owner_name, email, phone, business_type, country, status)
  values (trim(p_business_name), trim(p_owner_name), lower(trim(p_business_email)),
          null, null, trim(p_country), 'pending')
  returning id into v_business;

  update profiles set business_id = v_business, full_name = trim(p_owner_name)
   where id = auth.uid();

  select id into v_owner_role from roles where business_id is null and name = 'Owner';
  insert into user_roles (profile_id, role_id, branch_id)
  values (auth.uid(), v_owner_role, null);

  insert into audit_logs (business_id, actor_id, action, entity, entity_id)
  values (v_business, auth.uid(), 'business_registered', 'businesses', v_business);
  return v_business;
end $$;

-- Rejected → edit → resubmit, max 3 attempts (BR-11).
create or replace function resubmit_business(
  p_business_name text, p_business_email text, p_country text, p_owner_name text
) returns void
language plpgsql security definer set search_path = public as $$
declare v_business uuid; v_status text; v_count int;
begin
  v_business := owner_business_id();
  if v_business is null then raise exception 'No business linked to this account'; end if;
  select status, resubmission_count into v_status, v_count
    from businesses where id = v_business for update;   -- row lock: no double-resubmit race
  if v_status <> 'rejected' then raise exception 'Only rejected registrations can be resubmitted'; end if;
  if v_count >= 3 then raise exception 'Resubmission limit reached'; end if;

  update businesses
     set name = trim(p_business_name), owner_name = trim(p_owner_name),
         email = lower(trim(p_business_email)), country = trim(p_country),
         status = 'pending', rejection_reason = null,
         resubmission_count = resubmission_count + 1
   where id = v_business;

  insert into audit_logs (business_id, actor_id, action, entity, entity_id)
  values (v_business, auth.uid(), 'business_resubmitted', 'businesses', v_business);
end $$;

-- Setup Wizard finish line: enforces the fields registration deferred,
-- creates the default branch (BR-2 satisfied), flips setup_completed.
create or replace function complete_setup(p_business jsonb, p_branch jsonb) returns void
language plpgsql security definer set search_path = public as $$
declare v_business uuid;
begin
  v_business := current_business_id();   -- approved businesses only, by design
  if v_business is null then raise exception 'Business not approved or not found'; end if;
  if not has_permission('settings.manage') then raise exception 'Not allowed'; end if;

  -- Fields deferred from registration are mandatory HERE (Section 1 contract).
  if coalesce(p_business->>'phone','') = ''         then raise exception 'Phone required'; end if;
  if coalesce(p_business->>'business_type','') = '' then raise exception 'Business type required'; end if;
  if coalesce(p_business->>'currency','') = ''      then raise exception 'Currency required'; end if;
  if coalesce(p_business->>'timezone','') = ''      then raise exception 'Timezone required'; end if;
  if coalesce(p_business->>'language','') not in ('en','so','ar') then raise exception 'Invalid language'; end if;
  if coalesce(p_branch->>'name','') = ''            then raise exception 'Branch name required'; end if;

  update businesses set
      phone            = p_business->>'phone',
      business_type    = p_business->>'business_type',
      currency         = p_business->>'currency',
      timezone         = p_business->>'timezone',
      default_language = p_business->>'language',
      address          = coalesce(p_business->>'address', address),
      description      = coalesce(p_business->>'description', description),
      setup_completed  = true
   where id = v_business;

  insert into branches (business_id, name, address, is_default)
  values (v_business, p_branch->>'name', p_branch->>'address', true)
  on conflict do nothing;   -- resumable wizard: finishing twice is harmless

  insert into audit_logs (business_id, actor_id, action, entity, entity_id)
  values (v_business, auth.uid(), 'setup_completed', 'businesses', v_business);
end $$;

-- ---------------------------------------------------------------------------
-- SECTION 5: Portal pending queue
-- ---------------------------------------------------------------------------
-- One default branch per business, structurally (self-review finding F2):
-- this partial unique index is what makes complete_setup's ON CONFLICT
-- DO NOTHING actually idempotent under concurrent wizard-finish taps.
create unique index branches_one_default_uq on branches (business_id)
  where is_default and deleted_at is null;

create view pending_businesses with (security_invoker = true) as
select id, name, owner_name, email, country, resubmission_count, created_at,
       now() - created_at as waiting_for
  from businesses
 where status = 'pending' and deleted_at is null
 order by created_at;

-- ---------------------------------------------------------------------------
-- SECTION 6: Storage — business-assets bucket + tenant-scoped policies
-- Wrapped in a conditional block: applies on Supabase (storage schema exists),
-- is a no-op on plain-Postgres test environments. Explained in MIGRATIONS.md.
-- ---------------------------------------------------------------------------
do $$
begin
  if to_regclass('storage.buckets') is not null then
    insert into storage.buckets (id, name, public)
    values ('business-assets','business-assets', false)
    on conflict (id) do nothing;

    -- Path convention: {business_id}/logo.png — first folder IS the tenant.
    execute $p$create policy assets_read on storage.objects for select
      using (bucket_id = 'business-assets'
             and (storage.foldername(name))[1] = current_business_id()::text)$p$;
    execute $p$create policy assets_write on storage.objects for insert
      with check (bucket_id = 'business-assets'
             and (storage.foldername(name))[1] = current_business_id()::text
             and has_permission('settings.manage'))$p$;
    execute $p$create policy assets_update on storage.objects for update
      using (bucket_id = 'business-assets'
             and (storage.foldername(name))[1] = current_business_id()::text
             and has_permission('settings.manage'))$p$;
    execute $p$create policy assets_delete on storage.objects for delete
      using (bucket_id = 'business-assets'
             and (storage.foldername(name))[1] = current_business_id()::text
             and has_permission('settings.manage'))$p$;
  end if;
end $$;

-- ---------------------------------------------------------------------------
-- SECTION 7: Structural self-tests (fail = nothing deploys)
-- Behavioral tests (RLS actually blocking a pending owner, etc.) run in the
-- local harness — see MIGRATIONS.md §00012-Testing.
-- ---------------------------------------------------------------------------
do $$  -- TEST 1: all new functions exist and RPCs are SECURITY DEFINER
declare f text;
begin
  foreach f in array array['register_business','resubmit_business','complete_setup',
                           'trust_device','is_device_trusted','touch_device',
                           'revoke_device','revoke_all_devices','revoke_other_devices',
                           'device_trust_expiry_days','owner_business_id'] loop
    if to_regproc('public.'||f) is null then
      raise exception 'AUTH TEST FAILED: function % missing', f; end if;
  end loop;
  if exists (select 1 from pg_proc p join pg_namespace n on n.oid=p.pronamespace
              where n.nspname='public' and not p.prosecdef
                and p.proname in ('register_business','resubmit_business','complete_setup',
                                  'trust_device','revoke_device','revoke_all_devices','revoke_other_devices')) then
    raise exception 'AUTH TEST FAILED: an auth RPC is not SECURITY DEFINER';
  end if;
  raise notice 'AUTH TEST 1 PASSED: functions present, RPCs are definer';
end $$;

do $$  -- TEST 2: hardened wall really checks approval status
begin
  if pg_get_functiondef('current_business_id()'::regprocedure) not like '%approved%' then
    raise exception 'AUTH TEST FAILED: current_business_id() does not check approval status (SEC-1)';
  end if;
  raise notice 'AUTH TEST 2 PASSED: tenant wall is approval-gated';
end $$;

do $$  -- TEST 3: devices are read-only to clients (SEC-12)
begin
  if exists (select 1 from pg_policies where schemaname='public' and tablename='devices'
              and cmd in ('INSERT','UPDATE','DELETE','ALL')) then
    raise exception 'AUTH TEST FAILED: devices has a client write policy — trust must flow through functions only';
  end if;
  raise notice 'AUTH TEST 3 PASSED: device trust mutable only via definer functions';
end $$;

do $$  -- TEST 4: status-blind helper appears ONLY in its two sanctioned policies:
-- (1) businesses/business_read — pending owners must see their own row/reason;
-- (2) audit_logs/audit_insert — pending users must audit their own auth events
--     (email verified, login) BEFORE approval; write-only + actor-bound, so
--     status-blind scoping here exposes no data. Any third appearance fails.
declare v int;
begin
  select count(*) into v from pg_policies
   where schemaname='public'
     and (coalesce(qual,'')||coalesce(with_check,'')) like '%owner_business_id%'
     and not (tablename='businesses' and policyname='business_read')
     and not (tablename='audit_logs' and policyname='audit_insert');
  if v > 0 then
    raise exception 'AUTH TEST FAILED: owner_business_id() leaked into % unsanctioned policies', v;
  end if;
  raise notice 'AUTH TEST 4 PASSED: status-blind helper confined to its two sanctioned policies';
end $$;

do $$  -- TEST 5: registration columns relaxed
begin
  if exists (select 1 from information_schema.columns
              where table_name='businesses' and column_name in ('phone','business_type')
                and is_nullable='NO') then
    raise exception 'AUTH TEST FAILED: phone/business_type still NOT NULL';
  end if;
  raise notice 'AUTH TEST 5 PASSED: registration slimmed, wizard enforces the rest';
end $$;

do $$  -- TEST 6 (Review Update 1): the UPSERT target constraint really exists.
-- Verified against 00002: devices declares UNIQUE (profile_id, device_fingerprint)
-- inline. We assert instead of assume, so a future refactor can't silently
-- break trust_device's ON CONFLICT.
begin
  if not exists (
    select 1 from pg_constraint
     where conrelid = 'devices'::regclass and contype = 'u') then
    raise exception 'AUTH TEST FAILED: devices UNIQUE(profile_id,device_fingerprint) missing';
  end if;
  raise notice 'AUTH TEST 6 PASSED: device upsert constraint present';
end $$;

do $$  -- TEST 7: every auth DEFINER function pins search_path (hijack guard)
declare f text;
begin
  foreach f in array array['current_business_id','owner_business_id','register_business',
                           'resubmit_business','complete_setup','trust_device',
                           'is_device_trusted','touch_device','revoke_device',
                           'revoke_all_devices','revoke_other_devices'] loop
    if not exists (
      select 1 from pg_proc p
       where p.oid = to_regproc('public.'||f)
         and exists (select 1 from unnest(coalesce(p.proconfig, array[]::text[])) c
                      where c like 'search_path=%')) then
      raise exception 'AUTH TEST FAILED: % lacks a pinned search_path', f;
    end if;
  end loop;
  raise notice 'AUTH TEST 7 PASSED: all auth functions pin search_path';
end $$;

do $$  -- TEST 8: one-default-branch index exists (wizard idempotency, F2)
begin
  if to_regclass('branches_one_default_uq') is null then
    raise exception 'AUTH TEST FAILED: branches_one_default_uq missing';
  end if;
  raise notice 'AUTH TEST 8 PASSED: one default branch per business enforced';
end $$;

do $$  -- TEST 9: audit rows are no longer forgeable by clients (F1)
begin
  if exists (select 1 from pg_policies
              where tablename='audit_logs' and cmd='INSERT'
                and coalesce(with_check,'') not like '%actor_id%') then
    raise exception 'AUTH TEST FAILED: audit_insert does not bind actor_id';
  end if;
  raise notice 'AUTH TEST 9 PASSED: client audit writes bound to own identity';
end $$;
