# Multi-Agent Pipeline Workflow

## Phase 0: Setup (Lead)
1. Parse RAILS_BACKEND_PLAN.md → create GitHub issues with specs
2. Create labels: phase-N, type, agent, PR labels
3. Create worktrees for independent tickets (wave 1)
4. Assign agent IDs (j1..jN) to issues
5. New issues default to **Backlog** on the project board — Lead moves them to **Todo** when ready for implementation (skip if already manually moved)
6. Document in `.agents/docs/reports/wave-N-setup.md`

## Phase 1: Implementation (Juniors — Parallel)
For each ticket in wave:
1. Junior reads issue + plan sections
2. Implements in worktree
3. Commits with co-author
4. Pushes branch
5. Opens PR with `Closes #N`
6. Junior moves ticket **Todo → In Progress → In Review** on the project board (skip step if already manually moved)
7. Junior replies with PR URL, sessionID

## Phase 2: Review (GLM — Per PR)
1. Lead spawns GLM reviewer with PR + issue context
2. GLM reviews diff, posts `REQUEST_CHANGES` or `COMMENT`
3. If `REQUEST_CHANGES`:
    - Reviewer moves ticket **In Review → In Progress** on the project board + `pr/changes-requested` (skip if already manually moved)
    - Lead sends change requests to junior's sessionID
    - Junior fixes, commits, pushes → auto-updates PR
    - Junior moves ticket back to **In Review** + `pr/reviewed-by-glm`
    - Loop to step 2 (max 3 rounds)
4. If clean:
    - Ticket stays in **In Review** + `pr/approved-by-lead` + `pr/merge-ready`

## Phase 3: Lead Approval
1. Lead personally re-reads final diff for each PR
2. If satisfied: posts approval comment with co-author
3. If blockers: one more fix round to junior
4. PRs remain unmerged — human merges from GitHub

## Phase 4: Wave Completion
1. Lead verifies each PR is merged, then moves ticket **In Review → Done** on the project board (skip if already manually moved) — only Lead may move to Done
2. Next wave unblocked → repeat from Phase 0
3. Final report: PR URLs, review loops, verdicts, escalations

## Wave 1 (Foundation — Backend) — Parallel
| Ticket | Focus | Agent |
|--------|-------|-------|
| #4 Phase 8 tunnel lock-down & release | Release candidate, tag v0.1.0 | j1 |
| #5 Phase 7 testing & QA | Request specs, model tests | j2 |
| #6 Phase 4 sync engine | sync_outbox, delta upload/download | j3 |
| #7 Phase 5 web admin dashboard | ERB/Hotwire ADMIN + MEMBER views | j4 |
| #8 Phase 2 API authentication | JWT, token blocklist, rate limiting | j5 |

## Escalation Protocol
- After 3 review loops: move issue to `Changes Requested` on the project board + lead comment on issue
- Security blockers: immediate lead intervention
- Build/test failures (env): documented, not junior fault

## Phase 7: Model Role Compliance & Daily Workflow Checklist ✅
(Applied for EVERY PR created by agents)

### Daily Workflow Checklist (MANDATORY for every PR)
```
- [ ] Model role enforcement verified: all implementation commits use correct model chain
  from .agents/config/models.yaml (primary + fallbacks respected)
- [ ] Co-author attribution verified on all commits/PRs:
  `Co-authored-by: <model> <model>@users.noreply.github.com`
- [ ] Fallback logs checked: `.agents/logs/model-fallback.log`
  (rotate weekly; >2 fallbacks/wave → escalate)
- [ ] Security checks verified:
    - No hardcoded secrets (ENV/.env only)
    - Strong Parameters on all mutable endpoints
    - SQL injection prevention (parameterized queries)
    - Role-based authorization (ADMIN vs MEMBER)
- [ ] Code standards verified:
    - Ruby 4.0.6, Rails 8.x idiomatic style
    - Strong Parameters, 404/409/422 handling
    - Optimistic locking (lock_version) → 409
    - Soft deletes (deleted_at)
    - public_id UUID exposed to API
- [ ] Tests verified:
    - Request specs for API endpoints
    - Model tests for business rules (80% cap, treasury not negative)
- [ ] Phase-specific checks:
    - Phase 2: JWT, token blocklist, max 3 admin sessions, rack-attack, CORS
    - Phase 4: sync_outbox after_commit, delta sync, conflict 409, tombstones
    - Phase 5: ERB/Hotwire views, concurrent-edit dialog (Discard/Save)
    - Phase 7: request specs, model tests, system tests, sync conflict test
    - Phase 8: production .env, RAILS_ENV=production smoke test, tag v0.1.0
```

### Checklist Enforcement Protocol
1. **Lead agent** verifies ALL PRs before labeling `pr/merge-ready`
2. **GLM reviewer** posts review including checklist summary in body
3. **Human merge** cannot proceed without checklist completion (enforced via GitHub branch protection rules)
4. **Escalation**: If any checklist item fails → return to junior for fixes → re-review loop

### PR Creation Gate
- PRs will be HELD in `In Review` on the project board until Daily Workflow Checklist is complete
- Lead agent signs off on checklist completion before updating status to `pr/merge-ready`
- Human operator merges only after checklist `100% complete`
