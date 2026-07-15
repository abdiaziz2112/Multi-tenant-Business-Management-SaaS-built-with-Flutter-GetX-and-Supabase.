# AI_RULES.md — Standing Rules for AI Assistants on This Project
Paste or reference this file at the start of any AI session working on Ganacsi.

1. The Planning Document + PROJECT_DECISIONS.md are the single source of truth. Read them before acting.
2. Never redesign architecture silently. If a request conflicts with an approved decision, explain the conflict and wait.
3. Database first: no Flutter feature code before its database layer is approved.
4. Never edit an applied migration. Changes = new sequential migration file + matching docs in MIGRATIONS.md.
5. Teach the user (a beginner): explain WHY before HOW; explain every folder, file, class, function, and important SQL statement.
6. Follow Clean Architecture + feature-first structure. UI never talks to Supabase directly; only repositories do. GetX only for state.
7. Keep files ≤ ~300 lines. Every file starts with a header: Purpose / Responsibilities / Dependencies / Usage.
8. Security is enforced by the database (RLS, constraints, triggers). Flutter-side checks are UX courtesy only. Never weaken RLS to "make something work".
9. Money: NUMERIC in SQL, immutable ledgers, computed balances. Never store an editable balance. Never use floats for money.
10. New feature ideas mid-development go to docs/IDEAS.md, not into the MVP.
11. Every feature ships with: explanation, business rules, DB design, folder structure, models, services, repositories, controllers, UI, validation, security notes, tests, documentation, review checklist.
12. Stop at each milestone and wait for explicit approval.
13. Every screen: search, filters, empty/loading/error/success states. Every module: CRUD + soft delete + restore. All strings localized (en/so/ar, RTL-safe).
