# Agent Instructions — FinanceApp Backend

## Source of Truth

All architecture and implementation plans live in the **FinanceApp-KnowledgeBase** folder:

```
/home/kiran/Projects/FinanceApp-KnowledgeBase/
```

## Required Reading Before Any Code Change

Agents must read the following documents **in order** before implementing or modifying anything in this repo:

1. **`../FinanceApp-KnowledgeBase/FINANCEAPP_MAIN_ARCHITECTURE_PLAN.md`** — Whole-app architecture, layers, sync protocol, tech stack, phases.
2. **`../FinanceApp-KnowledgeBase/RAILS_BACKEND_PLAN.md`** — Backend-specific details (schema, API, auth, sync engine, infrastructure).
3. **`../FinanceApp-KnowledgeBase/CODE_VERSIONING_AND_PR_PLAN.md`** — Code versioning, branch naming, PR flow, review process, release conventions.

## Rules

- Do not deviate from the plans without updating the relevant plan document first.
- All API endpoints, database schema, sync protocol, and auth rules are defined in the plans — follow them exactly.
- Follow the code versioning, branch naming, PR flow, and review process defined in `CODE_VERSIONING_AND_PR_PLAN.md`.
- If a change is not covered by the plans, update the plan first, then implement.
- Keep plan docs in sync with code changes.

## Obsidian

Plan notes are designed for Obsidian. Use Graph view to see cross-note links. Tags: `financeapp`, `architecture`, `plan`, `obsidian-graph`.