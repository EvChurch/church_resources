---
date: 2026-03-27
topic: heroku-to-railway
---

# Migrate from Heroku to Railway

## Problem Frame
The app (resources.ev.church) is hosted on Heroku and needs to move to Railway. This is a Rails 7.2 app (Ruby 3.4) with PostgreSQL, Redis, S3 storage, Mailgun email, and Rollbar error tracking.

## Requirements
- R1. Deploy the Rails app on Railway with the same services: PostgreSQL, Redis, web process
- R2. Migrate the Heroku Postgres database to Railway Postgres via pg_dump/pg_restore
- R3. Configure all environment variables on Railway (DATABASE_URL, REDIS_URL, RAILS_MASTER_KEY, AWS credentials, MAILGUN keys, ROLLBAR token, etc.)
- R4. Run the release command (db:migrate) on deploy — Railway supports this via Procfile or deploy hooks
- R5. Switch DNS for resources.ev.church to point to Railway
- R6. Verify the app works end-to-end: page loads, admin login, file uploads (S3), email delivery

## Constraints
- CLI access to both Heroku (`heroku` CLI) and Railway (`railway` CLI) is available — the migration can be executed directly via commands rather than manual UI steps

## Scope Boundaries
- Some downtime (15-30 min) during cutover is acceptable
- Database is small (under 5 GB) — simple pg_dump/pg_restore
- S3 storage stays as-is (no migration needed, just keep the same AWS credentials)
- Mailgun, Rollbar, and other external services stay as-is (just re-set env vars)
- No Rails version upgrade or code changes beyond what Railway requires
- Heroku teardown is out of scope (keep it until Railway is confirmed stable)

## Success Criteria
- App is live on Railway at resources.ev.church
- All existing functionality works (pages, admin, uploads, emails)
- Deploys from the same Git repo work on Railway

## Key Decisions
- **Downtime acceptable**: Simple cutover approach — no need for parallel running or DB replication
- **Database transfer**: pg_dump from Heroku, pg_restore to Railway
- **External services unchanged**: S3, Mailgun, Rollbar stay on same providers

## Next Steps
→ `/ce:plan` for structured implementation planning
