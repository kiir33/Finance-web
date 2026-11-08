# FinanceApp Backend (Ruby on Rails)

This is the Rails backend implementation for FinanceApp.

## Source of Truth

All architecture and implementation plans live in the **FinanceApp-KnowledgeBase** folder:

```
/home/kiran/Projects/FinanceApp-KnowledgeBase/
```

Agents and developers must read the plan documents **before** making any code changes:

| Document | Purpose |
|----------|---------|
| [FINANCEAPP_MAIN_ARCHITECTURE_PLAN.md](../FinanceApp-KnowledgeBase/FINANCEAPP_MAIN_ARCHITECTURE_PLAN.md) | Whole-app architecture (mobile + backend + sync + infrastructure) |
| [RAILS_BACKEND_PLAN.md](../FinanceApp-KnowledgeBase/RAILS_BACKEND_PLAN.md) | Backend-specific plan: schema, API, auth, sync, infrastructure |
| [MOBILE_ANDROID_PLAN.md](../FinanceApp-KnowledgeBase/MOBILE_ANDROID_PLAN.md) | Android client plan |
| [DEPLOYMENT_PLAN.md](../FinanceApp-KnowledgeBase/DEPLOYMENT_PLAN.md) | Cloud deployment plan (draft) |

See [`AGENTS.md`](./AGENTS.md) for agent instructions.

## Setup

```bash
# Copy environment config
cp .env.example .env  # or use existing .env

# Install gems
bundle install

# Create and seed the database
bin/rails db:create db:migrate db:seed

# Start the server (Phase 1: local + tunnel)
bin/rails server -b 0.0.0.0 -p 3000

# Expose via tunnel for mobile clients
cloudflared tunnel --url http://localhost:3000
```

## Default Seed Accounts

| Email | Password | Role |
|-------|----------|------|
| admin@financeapp.local | admin123 | ADMIN |
| member@financeapp.local | member123 | MEMBER |

## API Endpoints

See `RAILS_BACKEND_PLAN.md` section 5 for full API design. Key endpoints:

- `POST /api/v1/auth/login` — JWT login
- `GET /api/v1/system_configs` — Read savings/loan configs (all users)
- `PATCH /api/v1/system_configs/:key` — Update config (ADMIN only)
- `POST/GET /api/v1/sync` — Delta sync upload/download

## Rules

- Do not deviate from the plans without updating the relevant plan document first.
- All API endpoints, database schema, sync protocol, and auth rules are defined in the plans — follow them exactly.
- Keep plan docs in sync with code changes.