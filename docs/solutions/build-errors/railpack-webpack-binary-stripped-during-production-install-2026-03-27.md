---
title: Railpack strips webpack binary before assets:precompile on Railway
date: "2026-03-27"
category: build-errors
module: deployment
problem_type: build_error
component: tooling
symptoms:
  - "No such file or directory - /app/node_modules/.bin/webpack (Errno::ENOENT)"
  - "bundle exec rake assets:precompile fails during Railway Railpack build"
  - "App builds fine locally and on Heroku but fails on Railway"
root_cause: config_error
resolution_type: config_change
severity: critical
rails_version: "7.2.3"
tags:
  - railway
  - railpack
  - webpack
  - shakapacker
  - heroku-migration
  - asset-precompile
related_components:
  - database
  - email_processing
---

# Railpack strips webpack binary before assets:precompile on Railway

## Problem

When deploying a Rails 7.2 app with Shakapacker (webpack) to Railway via Railpack, the build fails because Railpack's pipeline strips the webpack binary from `node_modules` before running `assets:precompile`.

## Symptoms

- Build fails with: `No such file or directory - /app/node_modules/.bin/webpack (Errno::ENOENT)`
- Error occurs during the `bundle exec rake assets:precompile` step of Railpack's build
- Sprockets assets (ActiveAdmin CSS, font-awesome) compile fine — only Shakapacker/webpack compilation fails
- The app builds fine locally and on Heroku

## What Didn't Work

1. **Adding `"build": "bundle exec rake assets:precompile"` to package.json** — Railpack ran this script but ALSO ran its own `assets:precompile` afterward, which still tried to invoke webpack after node_modules was stripped.

2. **Setting `RAILS_ASSETS_PRECOMPILE=false` env var** — Railpack does not respect this environment variable; it runs `assets:precompile` regardless.

3. **Setting `NODE_ENV=production` env var** — Does not prevent `yarn install --production=true` from stripping the webpack binary.

## Solution

Two coordinated changes:

### 1. Disable Shakapacker's hook into `assets:precompile`

In `config/shakapacker.yml`, set `shakapacker_precompile: false` in the production section:

```yaml
# config/shakapacker.yml
production:
  <<: *default
  compile: false
  shakapacker_precompile: false  # Prevents assets:precompile from invoking webpack
  extract_css: true
  cache_manifest: true
```

### 2. Run webpack in the package.json `build` script

Add a `build` script that runs webpack directly, then runs Sprockets-only asset precompilation:

```json
{
  "scripts": {
    "build": "NODE_ENV=production webpack --config config/webpack/webpack.config.js && RAILS_ENV=production bundle exec rake assets:precompile"
  }
}
```

## Why This Works

Railpack's build pipeline has this ordering:

1. `yarn install --frozen-lockfile` (full install — webpack is present)
2. **`yarn run build`** (runs our build script — webpack compiles JS packs, then Sprockets compiles CSS)
3. `yarn install --production=true` (strips dev deps — webpack binary is removed)
4. `bundle exec rake assets:precompile` (now only runs Sprockets since `shakapacker_precompile: false`, no webpack needed)

The key insight: Railpack executes `package.json` scripts during step 2, before the production strip in step 3. By moving webpack compilation to the `build` script and disabling Shakapacker's hook into `assets:precompile`, webpack runs when it's available and isn't needed later.

## Secondary Issues Encountered During This Migration

### Puma pidfile crash in containers

Container images don't have `tmp/pids/` pre-created. Puma crashes with `Errno::ENOENT` when writing `tmp/pids/server.pid`.

```ruby
# config/puma.rb — fix
pidfile_path = ENV.fetch('PIDFILE') { 'tmp/pids/server.pid' }
FileUtils.mkdir_p(File.dirname(pidfile_path))
pidfile pidfile_path
```

### pg_restore version mismatch

Heroku Postgres 17 dumps use format version 1.16, which pg_restore v16 can't read. Install `postgresql-client-17` from the PostgreSQL APT repository to match.

### Railway Postgres extensions

Railway Postgres (v18) only enables `plpgsql` by default. Apps using UUID primary keys need `pgcrypto` and `uuid-ossp` created before `pg_restore`:

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### Credential consolidation

Moving secrets from ENV vars into Rails encrypted credentials (`rails credentials:edit --environment production`) reduces the Railway env var surface to 6 infrastructure-only vars: `DATABASE_URL`, `REDIS_URL`, `RAILS_MASTER_KEY`, `RAILS_ENV`, `RAILS_SERVE_STATIC_FILES`, `RAILS_LOG_TO_STDOUT`.

## Prevention

- **When using Shakapacker/webpack with Railpack**: always set `shakapacker_precompile: false` in production and run webpack in the `build` script. This applies to any container PaaS that strips dev dependencies before running `assets:precompile`.
- **Test container builds locally**: run `yarn install --production=true` then `bundle exec rake assets:precompile` to catch missing binary issues before deploying.
- **Puma in containers**: always `mkdir_p` the pidfile directory. This is a common gotcha when moving from Heroku (persistent filesystem) to containers.
- **Database migrations**: match `postgresql-client` version to the source database version before dump/restore. Check target database extensions before restoring.
- **Secrets**: default to Rails encrypted credentials for application secrets from project inception. Reserve ENV vars for infrastructure concerns injected by the platform.

## Related Issues

- [Migration plan](../../plans/2026-03-27-001-refactor-heroku-to-railway-migration-plan.md) — full implementation plan for this migration
- [Rails upgrade solution](../best-practices/rails-upgrade-dual-asset-pipeline-patterns-2026-03-27.md) — documents the dual asset pipeline (Shakapacker + Sprockets) that made this build issue possible
- `docs/todos/mailgun-env-fetch-crash.md` — now obsolete (Mailgun replaced by Resend, ENV.fetch calls replaced by credentials.dig)
