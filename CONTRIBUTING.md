# Contributing Guidelines — FinanceApp Backend (Ruby on Rails)

> **Source of truth**: [[../../FinanceApp-KnowledgeBase/CODE_VERSIONING_AND_PR_PLAN.md]] (cross-repo code versioning, PR flow, review process).
> **Related**: [[../../FinanceApp-KnowledgeBase/FINANCEAPP_MAIN_ARCHITECTURE_PLAN.md]], [[../../FinanceApp-KnowledgeBase/RAILS_BACKEND_PLAN.md]], [[../FinanceApp/CONTRIBUTING.md]] (mobile repo contributing guidelines).

This repo follows the same code versioning, PR flow, and review process as the mobile repo (`FinanceApp/`). Read the common doc first, then the repo-specific details below.

---

## 1. Pull Requests

### Link GitHub Issues

Every PR **must** reference the GitHub issue it addresses. Include a `Closes #<issue-number>` or `Refs #<issue-number>` line in the PR description so the issue is automatically closed or linked when the PR is merged.

Example:

```
Closes #47
```

or

```
Refs #22
```

### PR Description Template

Use the template in `.github/PULL_REQUEST_TEMPLATE.md` when opening a PR.

### Branch Naming

| Type | Prefix | Example |
|------|--------|---------|
| Feature | `feat/` | `feat/add-system-configs-endpoint` |
| Fix | `fix/` | `fix/sync-outbox-duplicate-index` |
| CI/Build | `ci/` | `ci/add-rails-test-workflow` |
| Docs only | `docs/` | `docs/update-api-endpoints` |
| Refactor | `refactor/` | `refactor/auth-concern` |
| Release | `release/` | `release/v1.0.0` |

### PR Title Casing — Release PRs

Release PRs must follow this exact format:

```
Release: v1.0.0
```

Or with a release type for major/minor/patch:

```
Major Release: v2.0.0
Minor Release: v1.1.0
Patch Release: v1.0.1
```

Do not use lowercase prefixes (e.g. `release: v1.0.0` or `feat: first release`). Capitalize `Release` and use the `vx.x.x` version format.

Non-release PRs may use conventional commit prefixes (`feat:`, `fix:`, `ci:`, etc.) with Title Case.

### Review Process

All PRs require review and passing CI checks before merging.

- At least one approval from a reviewer who is not the author.
- CI build + test checks must be green.
- No self-merge.
- Squash merge into `main`.
- Delete feature branch after merge.

---

## 2. Versioning

The Rails backend uses Git tags on `main` following Semantic Versioning (`MAJOR.MINOR.PATCH`).

| Change Type | Version Segment | Example |
|-------------|----------------|---------|
| Breaking API changes | MAJOR | `v1.0.0` → `v2.0.0` |
| New backward-compatible features | MINOR | `v1.0.0` → `v1.1.0` |
| Bug fixes / patches | PATCH | `v1.0.0` → `v1.0.1` |

---

## 3. Repo-Specific Setup

See [`README.md`](./README.md) for environment setup, database creation, seeding, and running the server.

### Running Tests

```bash
bin/rails test
```

### Linting

```bash
bin/rubocop
```

---

## 4. Cross-Repo Alignment

When making changes that affect both repos (e.g. API contract changes, sync protocol changes):

1. Update the plan docs in `FinanceApp-KnowledgeBase/` first.
2. Implement in the backend repo (`financeapp_backend/`).
3. Implement in the mobile repo (`FinanceApp/`).
4. Reference the shared issue/PR across both repos.