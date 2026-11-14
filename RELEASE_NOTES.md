# FinanceApp Backend — Release v0.1.0 (Release Candidate)

## Tag
`rails-backend-v0.1.0`

## What's included (Phase 1)
- Phase 2: API authentication — JWT access tokens, token blocklist, max 3
  concurrent admin sessions, rate limiting (rack-attack), CORS for tunnel
- Phase 4: Sync engine — sync_outbox population via after_commit callbacks,
  delta upload/download, lock_version conflict detection (HTTP 409), soft-delete
  tombstones, per-device sync_states
- Phase 7: Testing & QA — request specs, model tests for business rules,
  sync conflict tests
- Phase 5: Web admin dashboard foundation — Tailwind CSS, shared layout/nav/
  flash partials, role-based access (require_admin! / require_member!), web
  CRUD controllers for members, loans, savings accounts, group accounts, system
  configs, audit logs, savings/loan/group transactions

## Release candidate checks (issue #4)
- [x] Tunnel restart procedure documented in .env (BASE_URL; update in device
  Settings on cloudflared restart — no app release required)
- [x] .env uses production-ready secret placeholders; no committed credentials
  (.env* is gitignored)
- [x] .env.production.example provided for production deployments
- [x] RAILS_ENV=production smoke test: Puma + Postgres, GET /up => 200

## Next (Phase 7+)
- Merge feature branches to main, then re-tag/release on main.
- Move tunnel to a custom domain with TLS.
