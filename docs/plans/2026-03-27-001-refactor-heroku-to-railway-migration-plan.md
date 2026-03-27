---
title: "refactor: Migrate hosting from Heroku to Railway"
type: refactor
status: active
date: 2026-03-27
origin: docs/brainstorms/2026-03-27-heroku-to-railway-requirements.md
deepened: 2026-03-27
---

# Migrate Hosting from Heroku to Railway

## Overview

Move the Rails 7.2 app (Ruby 3.4.9, resources.ev.church) from Heroku to Railway. The app uses PostgreSQL, Redis, S3, and Rollbar. Email delivery switches from Mailgun to Resend as part of the migration. Minimal code changes expected — `build` script for Railpack, credentials consolidation, and email provider swap. Some downtime (15-30 min) during cutover is acceptable.

## Problem Frame

The app is currently hosted on Heroku and needs to move to Railway. This is a straightforward infrastructure migration — the app has no background jobs, no cron tasks, and no Heroku-specific configuration files. The only services to provision on Railway are PostgreSQL and Redis. External services (S3, Rollbar) stay on their current providers. Email delivery switches from Mailgun to Resend (simpler API-based delivery, single API key via credentials). (see origin: docs/brainstorms/2026-03-27-heroku-to-railway-requirements.md)

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
- S3, Rollbar stay as-is — credentials consolidated
- Email delivery migrates from Mailgun to Resend (gem swap + config change)
- No Rails version upgrade; code changes limited to Railway build config, credentials consolidation, and email provider swap
- Heroku teardown is out of scope — keep until Railway is confirmed stable
- CI/CD (.github/workflows/main.yml) stays on GitHub Actions — no change needed

## Context & Research

### Relevant Code and Patterns

- `Procfile` — contains `web:` and `release:` commands. Railway supports Procfiles for simple single-service apps, though a prior migration (Rails 8 app) found Railway's per-service model preferred. For this single-service app, the Procfile should work as-is.
- `config/puma.rb` — uses `ENV['PORT']` (default 5000), single-process threaded mode (workers commented out), max 5 threads via `RAILS_MAX_THREADS`
- `config/environments/production.rb` — requires `RAILS_SERVE_STATIC_FILES` and `RAILS_LOG_TO_STDOUT` (still needed in Rails 7.2, unlike Rails 8 where these are defaults). Currently uses `ENV.fetch('MAILGUN_API_KEY')` for email — will be replaced with Resend via credentials.
- `config/database.yml` — no `production:` block exists; Rails auto-configures from `DATABASE_URL` (standard convention)
- `config/cable.yml` — production uses `REDIS_URL` with `ssl_params: { verify_mode: 'none' }` and channel prefix `church_resources_production`
- `config/storage.yml` — S3 via `ENV.fetch('AWS_BUCKET')`. Credentials resolved via AWS SDK default chain (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION` env vars) — not specified in YAML
- `config/application.rb` — UUID primary keys (`primary_key_type: :uuid`), Rack::Deflater, CORS for `ev.church` subdomains, timezone Auckland
- `config/shakapacker.yml` — Shakapacker 9.5+ with Babel, production: `compile: false`, `shakapacker_precompile: true`
- Dual asset pipeline: Shakapacker (JS/webpack) + dartsass-sprockets (CSS via Sprockets for ActiveAdmin)
- `package.json` — Yarn Classic 1.22.22 as `packageManager`, Node 22 in CI
- `.ruby-version` — Ruby 3.4.9
- No production Dockerfile or `railway.json` exists

### Institutional Learnings

- **Ruby 3.4 stdlib removals** (from Rails upgrade solution): Ruby 3.4 removed `mutex_m` and `drb` from stdlib — these are explicit gems in the Gemfile. Critical for Railpack builds where the environment differs from Heroku buildpacks.
- **Dual asset pipeline risk** (from Rails upgrade solution): Shakapacker + Sprockets both run during `assets:precompile`. If either fails silently, ActiveAdmin renders without styles. The `shakapacker_precompile: true` config triggers both pipelines.
- **Prior Railway migration learnings** (from solution doc, different Rails 8 project):
  - Railway's Railpack builder requires a `build` script in `package.json` for asset compilation
  - Railway's GraphQL API for env var management can return "Not Authorized" — prefer CLI
  - Procfile removal may be needed for multi-service apps (not applicable here — single service)
  - Audit env vars against credentials to find duplicates and drift
  - Mailgun SMTP credentials are not portable — switched to Resend API (single key, `delivery_method: :resend`)

### Environment Variables Inventory

**Remaining as env vars on Railway (infrastructure only):**

| Variable | Source | Notes |
|---|---|---|
| `DATABASE_URL` | Railway Postgres plugin | Auto-injected by Railway |
| `REDIS_URL` | Railway Redis plugin | Auto-injected by Railway |
| `RAILS_MASTER_KEY` | Heroku config | Decrypts credentials — must be env var |
| `RAILS_SERVE_STATIC_FILES` | Set to `true` | Still needed in Rails 7.2 |
| `RAILS_LOG_TO_STDOUT` | Set to `true` | Still needed in Rails 7.2 |
| `RAILS_ENV` | Set to `production` | Runtime flag |

**Consolidated into Rails encrypted credentials:**

| Env Var | Credential Path | Code Change Required |
|---|---|---|
| `SECRET_KEY_BASE` | `secret_key_base` | None — Rails reads from credentials automatically |
| `MAILGUN_API_KEY` | *(removed)* | Replaced by Resend — `resend.api_key` in credentials |
| `MAILGUN_DOMAIN` | *(removed)* | No longer needed — Resend uses API key only |
| *(new)* | `resend.api_key` | `production.rb` — replace Mailgun config with Resend |
| `ROLLBAR_ACCESS_TOKEN` | `rollbar.access_token` | `rollbar.rb` — change `ENV[]` to `credentials.dig` |
| `AWS_BUCKET` | `aws.bucket` | `storage.yml` — change `ENV.fetch` to `credentials.dig` |
| `AWS_ACCESS_KEY_ID` | `aws.access_key_id` | `storage.yml` — add explicit credential references |
| `AWS_SECRET_ACCESS_KEY` | `aws.secret_access_key` | `storage.yml` — add explicit credential references |
| `AWS_REGION` | `aws.region` | `storage.yml` — add explicit credential reference |
| `FB_APP_ID` | `facebook.app_id` | Only if actually used in app code |
| `FB_APP_SECRET` | `facebook.app_secret` | Only if actually used in app code |

**Notes:**
- `PORT` is set automatically by Railway — do not set manually
- `DATABASE_URL` and `REDIS_URL` are auto-injected when Railway plugins are attached
- Consolidating secrets into credentials eliminates drift between env vars and credential file (learned from prior Railway migration)

### External References

- Prior Railway migration solution doc (Rails 8 app) — documents Railpack build script requirement, Procfile incompatibility for multi-service, Mailgun→Resend switch, and env var audit practices

## Key Technical Decisions

- **Railpack as primary builder, Dockerfile as fallback**: Railway's Railpack is the Ruby/Rails-specific builder that auto-detects Ruby/Rails apps from the Gemfile. However, this app has a non-trivial build matrix: Ruby 3.4.9 (bleeding edge), Shakapacker + Sprockets dual pipeline, Yarn Classic, Node 22, and ImageMagick runtime dependency. A prior Railway migration confirmed Railpack requires a `build` script in `package.json`. **If the first Railpack build fails**, fall back to a Dockerfile using the devcontainer's system dependency list as reference.
- **Add `build` script to `package.json`**: Based on the prior Railway migration learnings, add `"build": "bundle exec rake assets:precompile"` to `package.json` scripts. Railpack looks for this script to trigger asset compilation, including both Shakapacker and Sprockets.
- **ImageMagick runtime dependency**: The app requires `imagemagick` and `libmagickwand-dev` at runtime (for `mini_magick` + `image_processing` gems used by Active Storage variants). Railpack may not install these automatically. If missing, configure via `RAILWAY_APT_PACKAGES=imagemagick,libmagickwand-dev` env var or fall back to a Dockerfile.
- **Switch email from Mailgun to Resend**: Following the prior Railway migration pattern, replace `mailgun-ruby` gem with `resend` gem. Resend uses a single API key via `delivery_method: :resend` — no SMTP host/port/auth config needed. The API key lives in encrypted credentials. Mailgun SMTP credentials are not portable across platforms; Resend's API approach is simpler. Also flip `raise_delivery_errors` to `true` since Resend API errors (invalid key, rate limits) are actionable.
- **Consolidate secrets into Rails encrypted credentials**: Following the pattern from the prior Railway migration, move application secrets (AWS, Resend, Rollbar, Facebook, SECRET_KEY_BASE) from env vars into `config/credentials/production.yml.enc`. Only infrastructure variables that Railway injects or that Rails needs before credentials are decrypted remain as env vars. This eliminates drift between env vars and credential files and reduces the Railway env var surface to 6 variables.
- **Railway Postgres + Redis plugins**: Use Railway's managed plugins rather than external services. They auto-inject connection URLs and handle provisioning.
- **Procfile kept**: For this single-service app, the existing Procfile works on Railway. The prior migration removed the Procfile because that app had multiple services (web + worker). This app only has a web process and release command.
- **Redis SSL verification**: Production Redis config uses `verify_mode: 'none'` — Railway Redis uses internal networking, so this is acceptable and already configured. If Railway Redis provides a plain `redis://` URL (no TLS), the `ssl_params` are harmless with recent redis-rb versions.

## Open Questions

### Resolved During Planning

- **Does Railway support the `release:` Procfile command?** Yes — Railway runs release commands before the web process starts on each deploy, same as Heroku.
- **Does Railpack handle Shakapacker/Yarn asset compilation?** Yes, but it requires a `build` script in `package.json` (confirmed by prior Railway migration). Add it proactively.
- **Ruby 3.4.9 Railpack support?** Railpack should support Ruby 3.4.9 via `.ruby-version` detection. If it cannot resolve the version, fall back to a Dockerfile. Verify during the test build (Unit 3).
- **Are `FB_APP_ID` / `FB_APP_SECRET` needed?** Not referenced in any config file. Grep application code before migrating — if unused, omit them.

### Deferred to Implementation

- **Railway Redis connection string format**: Verify whether Railway Redis uses `redis://` or `rediss://` (TLS) — may affect the `ssl_params` in `cable.yml` and `production.rb`. Check after provisioning.
- **Custom domain SSL**: Railway provides automatic SSL for custom domains — verify it works for resources.ev.church after DNS switch.
- **Node version on Railpack**: CI uses Node 22. Railpack will choose its own Node version. If asset compilation behaves differently, pin via `.node-version` file.
- **Postgres version alignment**: Document both Heroku and Railway Postgres versions before cutover. Ensure `pg_dump` client version >= source database version.

## Implementation Units

- [ ] **Unit 1: Create Railway project, provision services, and verify prerequisites**

  **Goal:** Set up the Railway project with PostgreSQL and Redis plugins. Verify Postgres extensions and version compatibility before any data migration.

  **Requirements:** R1

  **Dependencies:** None — first step

  **Approach:**
  - Create a new Railway project and add PostgreSQL and Redis plugins
  - Confirm both plugins are running and connection URLs are available
  - Connect to Railway Postgres and verify required extensions can be created: `pgcrypto` (used by all UUID primary keys via `gen_random_uuid()`), `plpgsql`, and `uuid-ossp`
  - Document the Railway Postgres version and compare to Heroku Postgres version
  - Check the `REDIS_URL` format — `redis://` vs `rediss://` — and note whether `ssl_params` adjustment is needed

  **Verification:**
  - Railway project exists with PostgreSQL and Redis plugins attached
  - `railway variables` shows `DATABASE_URL` and `REDIS_URL` are set
  - All three Postgres extensions (`pgcrypto`, `plpgsql`, `uuid-ossp`) are available
  - Postgres versions documented for both platforms

- [ ] **Unit 2: Switch email to Resend and consolidate secrets into credentials**

  **Goal:** Replace Mailgun with Resend for email delivery. Move all application secrets from env vars into Rails encrypted credentials. This reduces the Railway env var surface, eliminates drift, and modernizes email delivery.

  **Requirements:** R3, R6

  **Dependencies:** Unit 1

  **Files:**
  - Modify: `Gemfile` (remove `mailgun-ruby`, add `resend`)
  - Modify: `config/environments/production.rb` (replace Mailgun config with Resend; replace remaining `ENV.fetch` calls with `credentials.dig`)
  - Create: `config/initializers/resend.rb` (configure Resend API key from credentials)
  - Modify: `config/storage.yml` (AWS settings: `ENV.fetch` → `credentials.dig`, add explicit credential references)
  - Modify: `config/initializers/rollbar.rb` (`ENV[]` → `credentials.dig`)
  - Modify: `config/credentials/production.yml.enc` (add all secrets)
  - Create: `config/credentials.example.yml` (document credential structure)

  **Approach:**
  - Export current values from Heroku via `heroku config -a <app-name>`
  - Grep app code for `FB_APP_ID` / `FB_APP_SECRET` — only include in credentials if actually used
  - **Gem swap:** Remove `mailgun-ruby` from Gemfile, add `resend`. Run `bundle install`.
  - **Resend initializer:** Create `config/initializers/resend.rb`:
    ```ruby
    Resend.api_key = Rails.application.credentials.dig(:resend, :api_key)
    ```
  - **Update production.rb email config:** Replace the entire Mailgun block:
    - Remove: `delivery_method: :mailgun` and `mailgun_settings` block
    - Add: `delivery_method: :resend`
    - Add: `perform_deliveries = true`
    - Change: `raise_delivery_errors` to `true` (Resend API errors are actionable, unlike SMTP relay errors)
  - Create or edit production credentials via `EDITOR=vi rails credentials:edit --environment production`
  - Add credential structure:
    ```
    secret_key_base: <from Heroku>
    resend:
      api_key: <obtain from Resend dashboard>
    rollbar:
      access_token: <from Heroku>
    aws:
      access_key_id: <from Heroku>
      secret_access_key: <from Heroku>
      region: <from Heroku>
      bucket: <from Heroku>
    facebook:  # only if used
      app_id: <from Heroku>
      app_secret: <from Heroku>
    ```
  - Update `storage.yml` Amazon service: replace `ENV.fetch('AWS_BUCKET')` with `credentials.dig(:aws, :bucket)` and add `access_key_id`, `secret_access_key`, `region` from credentials
  - Update `rollbar.rb`: replace `ENV['ROLLBAR_ACCESS_TOKEN']` with `Rails.application.credentials.dig(:rollbar, :access_token)`
  - Remove `SECRET_KEY_BASE` env var — Rails reads it from credentials automatically
  - Remove `MAILGUN_API_KEY` and `MAILGUN_DOMAIN` env vars — no longer needed
  - Create `config/credentials.example.yml` documenting the structure (checked in, no real values)
  - **Set up Resend:** Create account, verify `ev.church` domain, obtain API key
  - **Deploy this to Heroku first** to verify credentials + Resend work before Railway migration

  **Patterns to follow:**
  - Prior Railway migration: switched from Mailgun SMTP to Resend API, consolidated secrets into encrypted credentials
  - Rails convention: `storage.yml` already has commented examples using `credentials.dig`

  **Test scenarios:**
  - App boots successfully on Heroku after changes (before Railway migration)
  - Resend email delivery works (send a test email from admin or console)
  - S3 uploads work via credentials
  - Rollbar error reporting works via credentials
  - `rails credentials:show --environment production` displays all expected keys
  - Default from address (`info@ev.church`) is verified in Resend

  **Verification:**
  - All tests pass with Resend + credentials-based config
  - Heroku deploy succeeds with only infrastructure env vars remaining
  - Test email received successfully via Resend
  - `config/credentials.example.yml` documents the full credential structure

- [ ] **Unit 3: Configure Railway environment variables with pre-deploy audit**

  **Goal:** Set the minimal required environment variables on Railway. After credential consolidation, only infrastructure vars remain.

  **Requirements:** R3

  **Dependencies:** Unit 1, Unit 2

  **Approach:**
  - Set each required variable on Railway via `railway variables set KEY=VALUE`
  - Required vars (only 4 to set manually): `RAILS_MASTER_KEY`, `RAILS_ENV=production`, `RAILS_SERVE_STATIC_FILES=true`, `RAILS_LOG_TO_STDOUT=true`
  - Do NOT set `DATABASE_URL`, `REDIS_URL`, or `PORT` — these are managed by Railway
  - After setting, audit: run `railway variables` and confirm all 6 infrastructure vars are present (4 manual + 2 auto-injected)
  - Verify no legacy application secrets are set as env vars — they should all be in credentials now

  **Verification:**
  - `railway variables` shows exactly the expected infrastructure variables
  - No application secrets present as env vars (Resend, AWS, Rollbar, Facebook, SECRET_KEY_BASE all in credentials)
  - `RAILS_MASTER_KEY` is set (required to decrypt credentials)

- [ ] **Unit 4: Add Railway build configuration and test deploy**

  **Goal:** Make the minimal code changes needed for Railpack, then verify the app builds and boots successfully. This is a test deploy — not yet serving real traffic or data.

  **Requirements:** R1, R4

  **Dependencies:** Unit 3

  **Files:**
  - Modify: `package.json` (add `build` script)
  - Optionally create: `.node-version` (pin Node 22 if Railpack chooses wrong version)

  **Approach:**
  - Add `"build": "bundle exec rake assets:precompile"` to `package.json` scripts (required by Railpack — confirmed by prior Railway migration)
  - Commit and push the `package.json` change (along with credential consolidation from Unit 2)
  - Link the Git repo to the Railway project and trigger a deploy
  - Monitor build logs closely for: Ruby 3.4.9 resolution, Node/Yarn detection, Shakapacker compilation, Sprockets compilation (ActiveAdmin CSS), ImageMagick availability
  - The `release:` command will run `rails db:migrate` against the empty Railway database — this is expected and creates the schema
  - If ImageMagick is missing from the Railpack build, configure via `RAILWAY_APT_PACKAGES=imagemagick,libmagickwand-dev` env var
  - **If Railpack fails** (Ruby version, missing deps, asset compilation): fall back to a Dockerfile using the devcontainer's system dependency list as reference

  **Patterns to follow:**
  - Prior Railway migration: added `build` script to `package.json`
  - Devcontainer Dockerfile: reference for system dependencies (`libpq-dev`, `libxml2-dev`, `libxslt1-dev`, `libyaml-dev`, `imagemagick`, `libmagickwand-dev`)

  **Test scenarios:**
  - Build completes with both Shakapacker and Sprockets assets compiled
  - Release phase (db:migrate) runs without error
  - App is accessible at the Railway-generated domain (*.up.railway.app)
  - Logs show Puma starting on the correct port
  - ActiveAdmin pages render with styles (confirms Sprockets worked)
  - Upload an image and request a variant (confirms ImageMagick is present)
  - Verify S3 connectivity: `rails runner "puts ActiveStorage::Blob.service.bucket.name"` returns the expected bucket

  **Verification:**
  - Build succeeds, app boots, and the Railway-generated domain loads
  - Asset compilation covers both pipelines (check for missing CSS on ActiveAdmin)
  - S3 connection resolves correctly

- [ ] **Unit 5: Migrate the database**

  **Goal:** Transfer all data from Heroku Postgres to Railway Postgres.

  **Requirements:** R2

  **Dependencies:** Unit 4 (app deploys and schema exists on Railway)

  **Approach:**
  - Put Heroku app in maintenance mode to prevent writes during migration
  - Record the current Heroku CNAME/DNS target value (needed for rollback)
  - Create a database dump from Heroku: `pg_dump` in custom format (`-Fc`)
  - Restore to Railway Postgres using `pg_restore --no-owner --no-privileges --single-transaction --clean --if-exists`
    - `--no-owner` / `--no-privileges`: Heroku role names differ from Railway's
    - `--single-transaction`: ensures the 17 cascade foreign keys are checked only at commit, preventing partial restores
    - `--clean --if-exists`: drops and recreates tables from Unit 3's initial schema creation
  - After restore, run verification checks (see below)

  **Test scenarios:**
  - Sequence reset: verify `active_storage_variant_records` sequence (the one table using integer serial PKs, not UUIDs) has `last_value >= MAX(id)` — restore can desync sequences
  - Foreign key integrity: for each FK constraint, confirm zero orphaned references
  - Active Storage: `SELECT DISTINCT service_name FROM active_storage_blobs` returns `amazon` (must match `config/storage.yml`)
  - Text field spot-check: compare a content-heavy resource record between source and target
  - Row counts: compare total row counts for ALL tables using `pg_stat_user_tables` on both sides

  **Verification:**
  - All tables have matching row counts between Heroku and Railway
  - Foreign key integrity holds across all 17 constraints
  - `active_storage_variant_records` sequence is correctly set
  - `active_storage_blobs.service_name` values all match `amazon`
  - App on Railway shows real data (sermons, users, etc.)
  - Admin login works with existing credentials

- [ ] **Unit 6: Switch DNS, verify end-to-end, and confirm rollback readiness**

  **Goal:** Point resources.ev.church to Railway, run the full verification checklist, and confirm rollback path is ready if needed.

  **Requirements:** R5, R6

  **Dependencies:** Unit 5

  **Approach:**
  - Add custom domain `resources.ev.church` to Railway project
  - Railway will provide a CNAME target
  - Update DNS records to point to Railway's CNAME
  - Wait for DNS propagation and SSL certificate provisioning
  - Run end-to-end verification checklist
  - Set a go/no-go deadline: if Railway is not fully verified within 2 hours of DNS switch, execute rollback

  **Verification checklist:**
  - Homepage loads at https://resources.ev.church
  - Admin panel loads and login works
  - ActiveAdmin pages render with styles
  - File upload to S3 works
  - Existing S3-hosted images/files display correctly
  - Image variant generation works (confirms ImageMagick)
  - Email delivery works (test via admin action or contact form)
  - Rollbar receives test error
  - SSL certificate is valid
  - Redis cache operations work (page caching, sessions persist across requests)
  - Subsequent deploys via git push trigger successful Railway builds

## Rollback Strategy

If Railway is broken post-DNS-switch:

1. **Flip DNS CNAME back** to the recorded Heroku target (from Unit 5)
2. **Disable Heroku maintenance mode** — Heroku still has the last-known-good database
3. **Accept data loss**: any writes that landed on Railway during the broken window are lost. This is acceptable for a low-traffic app.
4. **Decision deadline**: if Railway is not fully verified within 2 hours of DNS switch, roll back. The rollback window narrows as time passes — once Heroku's database is stale by hours, reverting sends users to old data.

## System-Wide Impact

- **DNS propagation**: After switching, some users may still hit Heroku for up to 24-48 hours (TTL-dependent). Keep Heroku in maintenance mode during this window.
- **Session invalidation**: Moving from Heroku Redis to Railway Redis means all existing sessions will be lost. Users will need to log in again. This is acceptable for this app.
- **Rollbar environment**: `ROLLBAR_ENV` falls back to `Rails.env` (production) — acceptable. No separate env var needed.
- **Action Cable origin checking**: `allowed_request_origins` is commented out in production.rb. Rails 7.2 defaults to same-origin. When testing on the `*.up.railway.app` temporary domain (Unit 4), Action Cable WebSocket connections will be rejected. This is expected and only verifiable after DNS switch to `resources.ev.church`.
- **S3 credential resolution**: After credential consolidation, `storage.yml` reads AWS credentials from `Rails.application.credentials`. The `RAILS_MASTER_KEY` env var must be set on Railway to decrypt them. The S3 connectivity check in Unit 4 catches misconfiguration early.
- **Container memory**: Railway's container may have different memory limits than Heroku dynos. Ruby 3.4 + Rails 7.2 + Shakapacker assets can consume 512MB+. Monitor memory usage after deploy.

## Risks & Dependencies

| Risk | Severity | Mitigation |
|---|---|---|
| Ruby 3.4.9 not supported by Railpack | High | Test build early (Unit 3). Dockerfile fallback ready. |
| ImageMagick missing from build | High | `RAILWAY_APT_PACKAGES` env var or Dockerfile fallback. Verify with variant generation test. |
| Missing `RAILS_MASTER_KEY` env var | High | Pre-deploy audit in Unit 3. Without it, credentials can't decrypt and app crashes. |
| Credential consolidation + Resend swap breaks Heroku deploy | Medium-High | Deploy to Heroku first (Unit 2) before Railway migration to verify. |
| Resend domain verification incomplete | Medium | Verify `ev.church` domain in Resend dashboard before deploy. Test email delivery on Heroku first. |
| Asset compilation fails (Shakapacker or Sprockets) | Medium-High | `build` script in `package.json`. Check ActiveAdmin styles post-deploy. |
| Node version mismatch | Medium | Pin via `.node-version` if Railpack chooses wrong version. |
| pg_restore sequence desync | Medium | Explicit sequence check for `active_storage_variant_records`. |
| Postgres extension unavailability | Medium | Pre-verify `pgcrypto`, `plpgsql`, `uuid-ossp` in Unit 1. |
| Database larger than expected | Medium | Test dump/restore timing before actual cutover. |
| Redis URL format (redis:// vs rediss://) | Medium | Check format in Unit 1 after provisioning. |
| No rollback after extended Railway use | Low-Medium | 2-hour go/no-go deadline. Keep Heroku in maintenance mode. |

## Sources & References

- **Origin document:** [docs/brainstorms/2026-03-27-heroku-to-railway-requirements.md](docs/brainstorms/2026-03-27-heroku-to-railway-requirements.md)
- **Prior migration learnings:** Rails 8 Heroku-to-Railway migration solution doc — build script requirement, Procfile behavior, env var audit practices
- **Rails upgrade solution:** `docs/solutions/best-practices/rails-upgrade-dual-asset-pipeline-patterns-2026-03-27.md` — Ruby 3.4 stdlib removals, dual asset pipeline risks
- Related code: `Procfile`, `config/puma.rb`, `config/environments/production.rb`, `config/database.yml`, `config/cable.yml`, `config/storage.yml`, `config/shakapacker.yml`, `config/application.rb`, `.ruby-version`, `package.json`
