# Feature: Device Management (Gate B.3)
**Purpose:** AUTH-007 registry UI — see every trusted device (name, platform, trusted/expiry/last-seen, current marker), remove one, or sign out everywhere.
**Business rules:** trust display mirrors `is_device_trusted` logic (DB stays authoritative); revoking the CURRENT device or using revoke-all ends this session immediately (next login = OTP gate); confirm dialogs state the consequence in plain language.
**Database:** deployed RPCs `revoke_device`, `revoke_all_devices` + registry read; no changes.
**Flutter:** `features/devices/` — DeviceManagementController (fingerprint seam for tests), screen with the four mandatory UI states + pull-to-refresh.
**Security:** mutations remain definer-function-only server-side; UI cannot self-trust.
**Testing:** three controller tests covering the revoke pairings.
**Future:** rename device; per-device activity log; admin view of employees' devices.
