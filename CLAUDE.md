# Project: [YOUR_PROJECT_NAME]

> Replace bracketed parts with your repo's specifics. Keep it under 200 words.
> Anything longer belongs in a sub-folder CLAUDE.md or a skill, not here.

## Map

- `apps/api/` — [stack, e.g. FastAPI], the only place auth lives
- `apps/web/` — [stack, e.g. Next.js], do NOT add API routes here, call `apps/api`
- `infra/` — [Terraform / Pulumi], ask before editing
- `scripts/` — utility scripts, safe to add

## Conventions

- Tests live next to code (`foo.py` → `foo_test.py`)
- Never import from `internal/` outside its module
- Secrets come from env, never inline
- New top-level deps require a one-line note to me first

## Don't

- Don't run migrations without my explicit ask
- Don't refactor `auth/` — there are subtle invariants
- Don't push to `main` directly — always a PR
- Don't write multi-paragraph docstrings; one short line max

---

*This file is loaded into every Claude Code conversation. Treat it as a router for the agent, not an encyclopedia. The full pattern: <https://ship-up.com/pillar-1.html>*
