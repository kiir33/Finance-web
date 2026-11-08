# FinanceApp Backend — Deployment Plan

> **Audience**: Lead engineer, DevOps, backend developers.
> **Status**: Draft.
> **Scope**: Deployment of the Ruby on Rails backend (API + web UI) to cloud infrastructure.
> **Source of truth**: [[../../FinanceApp-KnowledgeBase/DEPLOYMENT_PLAN.md]] (cross-repo overview).
> **Related**: [[../../FinanceApp-KnowledgeBase/RAILS_BACKEND_PLAN.md]]

---

## 1. Overview

Deploy the Rails backend to AWS or Azure as a containerized app with a managed PostgreSQL database. Replaces the Phase 1 cloudflared tunnel with a stable production domain.

## 2. Components to Deploy

### 2.1 Rails app container

- **Dockerfile** based on Ruby 4.0.x + Rails 8.x.
- `bin/rails server -b 0.0.0.0 -p 3000` via Puma.
- Environment variables: `DATABASE_URL`, `SECRET_KEY_BASE`, `API_TOKEN_SECRET`, `RAILS_ENV=production`, `RAILS_LOG_TO_STDOUT=1`, `CORS_ORIGINS`.
- Health check endpoint: `GET /up` or `GET /healthz`.

### 2.2 PostgreSQL

- Managed service (RDS / Azure Database for PostgreSQL).
- Same schema as local dev (`users`, `clients`, `loans`, `savings_*`, `group_*`, `system_configs`, `sync_*`, `audit_logs`).
- Connection via `DATABASE_URL` with SSL required.
- Daily automated backups; point-in-time recovery.

### 2.3 Domain + TLS

- Custom domain (e.g. `financeapp.example.com`).
- Managed certificate (ACM / Azure Managed Certificates).
- HTTPS termination at load balancer or app platform.

## 3. Provider Options

Pick one provider. Do not split across AWS and Azure.

| Component | AWS Option | Azure Option |
|-----------|------------|--------------|
| Compute | EC2, ECS (Fargate), Elastic Beanstalk | VM, Container Apps, App Service |
| Database | RDS PostgreSQL | Azure Database for PostgreSQL |
| TLS / Domain | Route53 + ACM | Azure DNS + Managed Certificates |
| Load balancer | ALB | Application Gateway / Front Door |
| Secrets | Secrets Manager | Key Vault |
| CI/CD | GitHub Actions or CodePipeline | GitHub Actions or Azure DevOps |
| Container registry | ECR | Azure Container Registry (ACR) |

## 4. Environment & Secrets

| Variable | Source | Notes |
|----------|--------|-------|
| `DATABASE_URL` | Secrets Manager / Key Vault | Managed DB connection string with SSL. |
| `SECRET_KEY_BASE` | Secrets Manager / Key Vault | Rails secret; rotate periodically. |
| `API_TOKEN_SECRET` | Secrets Manager / Key Vault | JWT signing secret. |
| `RAILS_ENV` | Platform env | `production`. |
| `RAILS_LOG_TO_STDOUT` | Platform env | `1` for container log capture. |
| `CORS_ORIGINS` | Secrets Manager / Key Vault | Production domain + admin web origins. |

- Never commit `.env` or secrets to git.
- Local dev keeps `.env` (Phase 1 flow unchanged).
- Production secrets injected by the hosting platform at runtime.

## 5. CI/CD Pipeline

### Suggested pipeline (GitHub Actions)

1. **Build**: Build Docker image on push to `main`.
2. **Test**: Run Rails request specs + model tests in container.
3. **Push**: Tag and push image to container registry (ECR / ACR).
4. **Deploy**: Roll out new image to app tier (blue/green or rolling).
5. **Migrate**: Run `bin/rails db:migrate` against production DB (with backup first).
6. **Notify**: Slack/email on success/failure.

### Deployment strategy

| Strategy | When |
|----------|------|
| Rolling update | Early production, low traffic |
| Blue/green | Once zero-downtime matters |
| Canary | Later, if needed |

## 6. Deployment Phases

| Phase | Focus | Deliverable |
|-------|-------|-------------|
| Phase 7a | Provider selection | Decide AWS vs Azure; create account/subscription. |
| Phase 7b | Infrastructure as code | Terraform / Bicep / platform CLI for VPC, DB, app tier, domain, TLS. |
| Phase 7c | Containerize Rails | Dockerfile, container registry, local build test. |
| Phase 7d | CI/CD pipeline | Build + test + deploy pipeline. |
| Phase 7e | Staging deploy | Deploy to staging; run end-to-end smoke tests. |
| Phase 7f | Production deploy | Point custom domain at production. |
| Phase 7g | Tunnel retirement | Document cloudflared shutdown; notify users to use production domain. |

## 7. Risks

| Risk | Mitigation |
|------|------------|
| Provider lock-in | Keep infrastructure as code simple; avoid provider-specific Rails features. |
| Managed DB cost | Start with smallest instance; scale only when metrics justify it. |
| Deployment breaks mobile sync | Keep tunnel available as fallback during cutover; test mobile `BASE_URL` switch. |
| Secret leakage | Never commit `.env`; use platform secret injection; rotate after any leak. |
| Migration failure in production | Backup DB before every migration; test migration on staging copy first. |

## 8. Obsidian Graph View Notes

- **Wikilinks**: `[[../../FinanceApp-KnowledgeBase/DEPLOYMENT_PLAN.md]]`, `[[../../FinanceApp-KnowledgeBase/RAILS_BACKEND_PLAN.md]]`
- **Tags**: `financeapp`, `backend`, `deployment`, `infrastructure`