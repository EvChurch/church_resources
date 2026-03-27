---
title: Fix CI POSTGRES_HOST env var mismatch
priority: p2
status: ready
source: code-review
---

# Fix CI POSTGRES_HOST env var mismatch

CI workflow sets `POSTGRES_HOST: postgres` but `database.yml` reads `DATABASE_HOST`. The CI variable is unused dead config. Either rename it to `DATABASE_HOST` or update `database.yml` to read `POSTGRES_HOST`.

**Files:** `.github/workflows/main.yml`, `config/database.yml`
