# KNOWN_LIMITATIONS.md — Honest List of What the MVP Does Not Do
Written down so nobody is surprised — least of all a paying customer.

1. **No offline mode.** POS requires connectivity. Mitigations: small payloads, retries. Roadmap v2.0.
2. **Single currency per business.** Mixed USD/SOS shops must pick one for the app. Revisit after pilot (IDEAS.md).
3. **GPS attendance reduces fraud, does not eliminate it.** Mock-location detection can be evaded on rooted devices; suspicious records are flagged for human review rather than trusted or silently blocked.
4. **Subscriptions are not billed.** Trials/plans are tracked; enforcement of plan limits and payment collection are manual/absent in MVP by directive.
5. **Collections auto-allocate oldest-first.** No per-sale payment picking yet.
6. **Support tickets are minimal** (single thread as JSONB); no SLA tooling.
7. **Reports render in-app only**; PDF/CSV export is v1.1.
8. **iOS is supported but Android is first-class**; pilot testing targets Android devices.
9. **Somali widget chrome is partially English.** App strings are fully Somali; Material's internal strings (date pickers, rare tooltips) fall back to English except key labels we override in SoMaterialLocalizations. Extend overrides as needed.
10. **Realtime dashboard depends on Supabase Realtime quotas**; very large businesses may see polling fallback later.
