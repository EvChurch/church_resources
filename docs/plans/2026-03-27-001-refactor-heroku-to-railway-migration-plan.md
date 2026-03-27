---
title: "refactor: Migrate hosting from Heroku to Railway"
type: refactor
status: active
date: 2026-03-27
origin: docs/brainstorms/2026-03-27-heroku-to-railway-requirements.md
---

# Migrate Hosting from Heroku to Railway

## Overview

Move the Rails 7.0 app (resources.ev.church) from Heroku to Railway. The app uses PostgreSQL, Redis, S3, Mailgun, and Rollbar. No code changes are expected beyond Railway-specific configuration. Some downtime (15-30 min) during cutover is acceptable.

## Problem Frame

The app is currently hosted on Heroku and needs to move to Railway. This is a straightforward infrastructure migration — the app has no background jobs, no cron tasks, and no Heroku-specific configuration files. The only services to provision on Railway are PostgreSQL and Redis. External services (S3, Mailgun, Rollbar) stay on their current providers. (see origin: docs/brainstorms/2026-03-27-heroku-to-railway-requirements.md)

## Requirements Trace

- R1. Deploy the Rails app on Railway with PostgreSQL, Redis, and web process
- R2. Migrate the Heroku Postgres database to Railway Postgres via pg_dump/pg_restore
- R3. Configure all environment variables on Railway
- R4. Run the release command (db:migrate) on deploy
- R5. Switch DNS for resources.ev.church to point to Railway
- R6. Verify end-to-end: page loads, admin login, file uploads (S3), email delivery

## Scope Boundaries

- Some downtime (15-30 min) during cutover is acceptable
- Database is small (under 5 GB)
- S3, Mailgun, Rollbar stay as-is — only env vars need re-setting
- No Rails version upgrade or app code changes
- Heroku teardown is out of scope — keep until Railway is confirmed stable
- CI/CD (.github/workflows/main.yml) stays on GitHub Actions — no change needed

## Context & Research

### Relevant Code and Patterns

- `Procfile` — already Railway-compatible (`web:` and `release:` commands)
- `config/puma.rb` — uses `ENV['PORT']` which Railway sets automatically
- `config/environments/production.rb` — requires `RAILS_SERVE_STATIC_FILES` and `RAILS_LOG_TO_STDOUT` for container-based hosting
- `config/database.yml` — production config uses `DATABASE_URL` (standard Rails convention, auto-detected)
- `config/cable.yml` — production uses `REDIS_URL` with `ssl_params: { verify_mode: 'none' }`
- `config/storage.yml` — S3 via `ENV['AWS_BUCKET']`
- No production Dockerfile exists — Railway can use Nixpacks (auto-detection for Ruby/Rails) or a Dockerfile

### Environment Variables Inventory

**Required on Railway:**

| Variable | Source | Notes |
|---|---|---|
| `DATABASE_URL` | Railway Postgres plugin | Auto-injected by Railway |
| `REDIS_URL` | Railway Redis plugin | Auto-injected by Railway |
| `RAILS_MASTER_KEY` | Heroku config | Copy from Heroku |
| `RAILS_SERVE_STATIC_FILES` | Set to `true` | Railway serves static files via Puma |
| `RAILS_LOG_TO_STDOUT` | Set to `true` | Railway captures stdout logs |
| `RAILS_ENV` | Set to `production` | |
| `SECRET_KEY_BASE` | Heroku config | Copy from Heroku |
| `AWS_BUCKET` | Heroku config | S3 bucket name |
| `AWS_ACCESS_KEY_ID` | Heroku config | S3 credentials |
| `AWS_SECRET_ACCESS_KEY` | Heroku config | S3 credentials |
| `AWS_REGION` | Heroku config | S3 region |
| `MAILGUN_API_KEY` | Heroku config | Email delivery |
| `MAILGUN_DOMAIN` | Heroku config | Default: ev.church |
| `ROLLBAR_ACCESS_TOKEN` | Heroku config | Error tracking |
| `FB_APP_ID` | Heroku config | Facebook integration |
| `FB_APP_SECRET` | Heroku config | Facebook integration |

**Notes:**
- `PORT` is set automatically by Railway — do not set manually
- `DATABASE_URL` and `REDIS_URL` are auto-injected when Railway plugins are attached

## Key Technical Decisions

- **Nixpacks over Dockerfile**: Railway's Nixpacks auto-detects Ruby/Rails apps from the Gemfile and Procfile. No Dockerfile is needed for this standard Rails stack. Nixpacks handles Ruby version detection (from `.ruby-version` or Gemfile), Node/Yarn for asset compilation, and Procfile-based process management. This avoids maintaining a production Dockerfile.
- **Railway Postgres + Redis plugins**: Use Railway's managed plugins rather than external services. They auto-inject connection URLs and handle provisioning.
- **Procfile unchanged**: The existing Procfile already works for Railway — `web:` for Puma and `release:` for db:migrate.
- **Redis SSL verification**: Production Redis config uses `verify_mode: 'none'` — Railway Redis uses internal networking so this is acceptable and already configured.

## Open Questions

### Resolved During Planning

- **Does Railway support the `release:` Procfile command?** Yes — Railway runs release commands before the web process starts on each deploy, same as Heroku.
- **Does Nixpacks handle Shakapacker/Yarn asset compilation?** Yes — Nixpacks detects `package.json` and runs `yarn install` and asset precompilation automatically.
- **Ruby 3.2.10 support?** Nixpacks supports Ruby 3.2.x. The version is specified in the Gemfile.

### Deferred to Implementation

- **Railway Redis connection string format**: Verify whether Railway Redis uses `redis://` or `rediss://` (TLS) — may affect the `ssl_params` in `cable.yml` and `production.rb`. Check after provisioning.
- **Custom domain SSL**: Railway provides automatic SSL for custom domains — verify it works for resources.ev.church after DNS switch.

## Implementation Units

- [ ] **Unit 1: Create Railway project and provision services**

  **Goal:** Set up the Railway project with PostgreSQL and Redis plugins.

  **Requirements:** R1

  **Dependencies:** None — first step

  **Approach:**
  - Use `railway init` to create a new project
  - Add PostgreSQL plugin via `railway add --plugin postgresql`
  - Add Redis plugin via `railway add --plugin redis`
  - Confirm both plugins are running and connection URLs are available

  **Verification:**
  - Railway project exists with PostgreSQL and Redis plugins attached
  - `railway variables` shows `DATABASE_URL` and `REDIS_URL` are set

- [ ] **Unit 2: Configure environment variables**

  **Goal:** Set all required environment variables on Railway, copied from Heroku.

  **Requirements:** R3

  **Dependencies:** Unit 1

  **Approach:**
  - Export current Heroku config vars via `heroku config -a <app-name>`
  - Set each required variable on Railway via `railway variables set KEY=VALUE`
  - Required vars: `RAILS_MASTER_KEY`, `SECRET_KEY_BASE`, `RAILS_ENV=production`, `RAILS_SERVE_STATIC_FILES=true`, `RAILS_LOG_TO_STDOUT=true`, AWS credentials (4 vars), `MAILGUN_API_KEY`, `MAILGUN_DOMAIN`, `ROLLBAR_ACCESS_TOKEN`, `FB_APP_ID`, `FB_APP_SECRET`
  - Do NOT set `DATABASE_URL`, `REDIS_URL`, or `PORT` — these are managed by Railway

  **Verification:**
  - `railway variables` shows all expected variables
  - No Heroku-specific or conflicting values present

- [ ] **Unit 3: Deploy the app to Railway**

  **Goal:** Get the Rails app building and running on Railway.

  **Requirements:** R1, R4

  **Dependencies:** Unit 2

  **Approach:**
  - Link the Git repo to the Railway project via `railway link`
  - Trigger a deploy via `railway up` or connect the GitHub repo for automatic deploys
  - Railway will use Nixpacks to detect Ruby, install gems, compile assets (Yarn + Shakapacker), and start Puma via the Procfile
  - The `release:` command in Procfile will run `rails db:migrate` on each deploy
  - Monitor build logs for errors — common issues: missing system dependencies, Node version mismatches

  **Verification:**
  - Build completes successfully
  - Release phase (db:migrate) runs without error
  - App is accessible at the Railway-generated domain (*.up.railway.app)
  - Logs show Puma starting and listening on the correct port

- [ ] **Unit 4: Migrate the database**

  **Goal:** Transfer all data from Heroku Postgres to Railway Postgres.

  **Requirements:** R2

  **Dependencies:** Unit 3 (app deploys and schema is created)

  **Approach:**
  - Put Heroku app in maintenance mode to prevent writes during migration
  - Create a database backup from Heroku via `heroku pg:backups:capture`
  - Download the backup via `heroku pg:backups:download`
  - Restore to Railway Postgres via `pg_restore` using the Railway `DATABASE_URL`
  - Alternative: direct `pg_dump` from Heroku piped to `pg_restore` on Railway if both are network-accessible
  - After restore, verify row counts on key tables match

  **Verification:**
  - Key tables have matching row counts between Heroku and Railway
  - App on Railway shows real data (sermons, users, etc.)
  - Admin login works with existing credentials

- [ ] **Unit 5: Switch DNS and verify**

  **Goal:** Point resources.ev.church to Railway and verify everything works.

  **Requirements:** R5, R6

  **Dependencies:** Unit 4

  **Approach:**
  - Add custom domain `resources.ev.church` to Railway project
  - Railway will provide a CNAME target
  - Update DNS records to point to Railway's CNAME
  - Wait for DNS propagation and SSL certificate provisioning
  - Run end-to-end verification checklist

  **Verification checklist:**
  - Homepage loads at https://resources.ev.church
  - Admin panel loads and login works
  - File upload to S3 works
  - Existing S3-hosted images/files display correctly
  - Email delivery works (test via admin action or contact form)
  - Rollbar receives test error
  - SSL certificate is valid
  - Subsequent deploys via git push trigger successful Railway builds

## System-Wide Impact

- **DNS propagation**: After switching, some users may still hit Heroku for up to 24-48 hours (TTL-dependent). Keep Heroku in maintenance mode during this window.
- **Session invalidation**: Moving from Heroku Redis to Railway Redis means all existing sessions will be lost. Users will need to log in again. This is acceptable for this app.
- **Rollbar environment**: Verify `ROLLBAR_ENV` is set correctly so errors are attributed to the right environment. If not set, it falls back to `Rails.env` which should be `production`.
- **Action Cable**: Production cable config uses `REDIS_URL` — will work with Railway Redis as long as the URL format is compatible. Verify after deploy.

## Risks & Dependencies

- **Database migration window**: The ~15-30 min downtime is during the pg_dump/restore + DNS switch. If the database is larger than expected, this window grows. Mitigate by testing the dump/restore timing before the actual cutover.
- **Nixpacks build compatibility**: If Nixpacks fails to auto-detect something (e.g., system library for image_processing/mini_magick), a Dockerfile may be needed as fallback. Monitor the first build closely.
- **Redis SSL format**: Railway Redis may use a different connection format than Heroku Redis. The existing `ssl_params: { verify_mode: 'none' }` config should handle most cases, but verify after provisioning.

## Sources & References

- **Origin document:** [docs/brainstorms/2026-03-27-heroku-to-railway-requirements.md](docs/brainstorms/2026-03-27-heroku-to-railway-requirements.md)
- Related code: `Procfile`, `config/puma.rb`, `config/environments/production.rb`, `config/database.yml`, `config/cable.yml`, `config/storage.yml`
