---
title: "fix: Resolve all outstanding TODOs"
type: fix
status: completed
date: 2026-03-27
---

# fix: Resolve all outstanding TODOs

## Overview

Resolve all 7 outstanding TODO items tracked in `docs/todos/` plus 1 inline TODO in the GraphQL mutation type. These are small, independent fixes spanning CI config, layouts, production config, JavaScript bundling, cache safety, Gemfile hygiene, and GraphQL cleanup. One TODO (Mailgun crash) is already resolved and just needs its tracking file removed.

## Problem Frame

Code review surfaced 7 tracked issues plus 1 inline TODO. Each is a small correctness, hygiene, or security concern that should be cleaned up. None require product decisions — they are all technical debt items.

## Requirements Trace

- R1. Fix CI env var mismatch so `DATABASE_HOST` is correctly set
- R2. Extract shared `<head>` content into a partial to eliminate layout duplication
- R3. Remove stale Expires header from production config
- R4. Remove core-js and regenerator-runtime polyfills and related Babel config
- R5. Sanitize `resource_type` param before including it in RSS cache key
- R6. Tighten all production Gemfile constraints to pessimistic `~>` at minor version
- R7. Remove scaffolded GraphQL test_field and unused mutation schema registration
- R8. Remove the resolved Mailgun TODO file
- R9. Remove each `docs/todos/` file as its TODO is resolved

## Scope Boundaries

- No new features or behavior changes
- Gemfile constraint changes should not change resolved versions (use current lockfile versions)
- Layout partial extraction preserves existing HTML exactly — no redesign
- Polyfill removal does not change browserslist targets

## Context & Research

### Relevant Code and Patterns

- `config/database.yml` reads `DATABASE_HOST` (line 6, 15) — CI sets `POSTGRES_HOST` instead
- `application.html.erb` and `devise.html.erb` share identical `<head>` blocks except devise lacks the GTM snippet
- `config/environments/production.rb:28` has the stale `Expires` header
- `app/javascript/packs/application.js:6-7` imports `core-js/stable` and `regenerator-runtime/runtime`
- `babel.config.js:32-33` configures `useBuiltIns: "entry"` with `corejs: 3`; lines 68-80 configure regenerator plugins
- `app/controllers/resources_controller.rb:16` inserts unvalidated `params[:resource_type]` into cache key
- `Resource::TYPES` keys are `:article` and `:sermon` (app/models/resource.rb:4)
- `app/graphql/types/mutation_type.rb` contains only scaffolded `test_field`
- No real mutations exist (`app/graphql/mutations/` has only `.keep`)
- Mailer already migrated from Mailgun to Resend — `MAILGUN_API_KEY` reference is gone from production.rb

### Institutional Learnings

- `docs/solutions/best-practices/rails-upgrade-dual-asset-pipeline-patterns-2026-03-27.md` documents the dual asset pipeline (Sprockets + Webpack) — relevant for polyfill removal to ensure only Webpack-owned files are touched

## Key Technical Decisions

- **CI env var**: Rename `POSTGRES_HOST` to `DATABASE_HOST` in the workflow (not the other way around) because `database.yml` is the canonical consumer and already uses `DATABASE_HOST`
- **Layout partial**: Extract to `app/views/layouts/_head.html.erb` with a parameter for GTM inclusion, since devise layout intentionally omits GTM
- **Polyfill removal**: Remove imports from application.js, remove `core-js` and `regenerator-runtime` from package.json, clean up related Babel config (`useBuiltIns`, `corejs`, regenerator plugins). Keep `@babel/plugin-transform-runtime` but set `regenerator: false`
- **Cache key fix**: Validate `params[:resource_type]` against `Resource::TYPES.keys.map(&:to_s)` before inserting into cache key, and skip it if invalid — consistent with how `rss_resources_scope` already validates
- **Gemfile constraints**: Use `~>` at minor version level (e.g., `~> 1.5` for pg 1.5.9) for production gems. For stdlib extraction gems (`drb`, `mutex_m`, `concurrent-ruby`) use `~>` at minor level as well. Dev/test gems get the same treatment
- **GraphQL cleanup**: Remove the `test_field` from `MutationType`, remove `mutation(Types::MutationType)` from the schema, since there are no real mutations. Leave the empty class file in case mutations are added later

## Open Questions

### Resolved During Planning

- **Is the Mailgun TODO already resolved?** Yes — `config/environments/production.rb` no longer references `MAILGUN_API_KEY`. The mailer uses `:resend` with credentials. Only the tracking file needs removal.
- **Should we remove the MutationType class entirely?** No — keep the empty class file but remove the schema registration. This avoids graphql-ruby raising on an empty type while preserving the file for future mutations.

### Deferred to Implementation

- **Exact browserslist behavior after polyfill removal**: The `defaults` query in 2026 targets modern browsers only. Verify webpack builds cleanly after removal.

## Implementation Units

- [x] **Unit 1: Fix CI DATABASE_HOST env var**

  **Goal:** Align CI workflow env var name with what `database.yml` reads

  **Requirements:** R1

  **Dependencies:** None

  **Files:**
  - Modify: `.github/workflows/main.yml`

  **Approach:**
  - Rename `POSTGRES_HOST: postgres` to `DATABASE_HOST: postgres` in the test job's `env` block (line 32)

  **Patterns to follow:**
  - The existing `POSTGRES_PASSWORD` and `POSTGRES_USER` vars follow PostgreSQL naming but `database.yml` uses `DATABASE_HOST` — fix the mismatch at the CI layer

  **Test scenarios:**
  - CI test job should continue to pass (env var now correctly consumed by database.yml)

  **Verification:**
  - `database.yml` reads `DATABASE_HOST` and the CI workflow sets `DATABASE_HOST`

- [x] **Unit 2: Extract shared head partial from layouts**

  **Goal:** Eliminate duplicated `<head>` content between application and devise layouts

  **Requirements:** R2

  **Dependencies:** None

  **Files:**
  - Create: `app/views/layouts/_head.html.erb`
  - Modify: `app/views/layouts/application.html.erb`
  - Modify: `app/views/layouts/devise.html.erb`

  **Approach:**
  - Extract the shared `<head>` content (Rollbar snippet, meta tags, csrf/csp tags, FontAwesome, pack tags, viewport meta) into `_head.html.erb`
  - The GTM snippet (lines 27-29 in application.html.erb) is only in the application layout — pass a local variable like `include_gtm: true` to control its inclusion
  - Both layouts render the partial instead of duplicating the content

  **Patterns to follow:**
  - Standard Rails partial with locals pattern: `<%= render 'layouts/head', include_gtm: true %>`

  **Test scenarios:**
  - Application layout includes Rollbar, meta tags, FontAwesome, pack tags, viewport, and GTM
  - Devise layout includes everything except GTM
  - No visual/behavioral change in rendered pages

  **Verification:**
  - Both layouts render identical `<head>` content as before (minus GTM difference)
  - No duplicated head markup remains in either layout file

- [x] **Unit 3: Remove stale Expires header**

  **Goal:** Remove the boot-time-evaluated Expires header that becomes stale

  **Requirements:** R3

  **Dependencies:** None

  **Files:**
  - Modify: `config/environments/production.rb`

  **Approach:**
  - Remove the `'Expires' => 1.year.from_now.to_fs(:rfc822).to_s` line from `config.public_file_server.headers`
  - `Cache-Control` with `max-age` and `s-maxage` already handles browser and CDN caching

  **Test scenarios:**
  - Production config loads without error
  - Only `Cache-Control` header remains in `public_file_server.headers`

  **Verification:**
  - The `Expires` key is gone from the headers hash

- [x] **Unit 4: Remove core-js and regenerator-runtime polyfills**

  **Goal:** Remove ~80-120KB of unnecessary polyfills for dead browser targets

  **Requirements:** R4

  **Dependencies:** None

  **Files:**
  - Modify: `app/javascript/packs/application.js`
  - Modify: `babel.config.js`
  - Modify: `package.json`

  **Approach:**
  - Remove `import "core-js/stable"` and `import "regenerator-runtime/runtime"` from application.js
  - In babel.config.js production/development preset: remove `useBuiltIns: "entry"` and `corejs: 3` (or set `useBuiltIns: false`)
  - Remove `@babel/plugin-transform-regenerator` plugin entirely (lines 75-80)
  - Set `regenerator: false` in `@babel/plugin-transform-runtime` (line 72)
  - Remove `core-js` and `regenerator-runtime` from package.json dependencies
  - Run `yarn install` to update yarn.lock

  **Patterns to follow:**
  - The app already uses `@hotwired/turbo-rails` which requires ES module support — confirming modern-only browser targets

  **Test scenarios:**
  - Webpack builds successfully in production mode
  - No runtime errors from missing polyfills (modern browsers have native support)

  **Verification:**
  - No references to `core-js` or `regenerator-runtime` in application.js
  - Babel config no longer configures core-js polyfill injection
  - `yarn.lock` updated without these packages

- [x] **Unit 5: Sanitize resource_type in RSS cache key**

  **Goal:** Prevent cache key pollution from invalid resource_type params

  **Requirements:** R5

  **Dependencies:** None

  **Files:**
  - Modify: `app/controllers/resources_controller.rb`
  - Test: `spec/requests/resources_spec.rb`

  **Approach:**
  - Validate `params[:resource_type]` against `Resource::TYPES.keys.map(&:to_s)` before appending to cache key
  - If the param is present but invalid, exclude it from the cache key (the scope already returns all resources for invalid types)
  - This aligns cache key construction with the actual query behavior in `rss_resources_scope`

  **Patterns to follow:**
  - `Resource::TYPES` is the canonical type registry (app/models/resource.rb:4)
  - `rss_resources_scope` already validates with `Resource::TYPES.key?(params[:resource_type].to_sym)`

  **Test scenarios:**
  - Valid `resource_type=sermon` → type included in cache key, scoped results cached
  - Valid `resource_type=article` → same
  - Invalid `resource_type=bogus` → type excluded from cache key, unfiltered results cached under generic key
  - Missing `resource_type` → no type in cache key, unfiltered results

  **Verification:**
  - Cache key only includes validated resource types
  - Invalid params cannot create separate cache entries for unfiltered results

- [x] **Unit 6: Tighten Gemfile version constraints**

  **Goal:** Standardize all gem constraints to pessimistic `~>` to prevent unexpected major version bumps

  **Requirements:** R6

  **Dependencies:** None

  **Files:**
  - Modify: `Gemfile`

  **Approach:**
  - Convert bare gems and `>=` gems to `~>` at minor version level based on current lockfile versions
  - Specific conversions (production gems):
    - `active_admin_datetimepicker` → `~> 1.1`
    - `active_storage_validations` → `~> 3.0`
    - `acts_as_list` → `~> 1.2`
    - `aws-sdk-s3` → `~> 1.217`
    - `bootsnap` → `~> 1.18`
    - `bootstrap4-kaminari-views` → `~> 1.0`
    - `concurrent-ruby` → `~> 1.3`
    - `dartsass-sprockets` → `~> 3.2`
    - `devise` → `~> 5.0`
    - `draper` → `~> 4.0`
    - `drb` → `~> 2.2`
    - `formtastic` → `~> 5.0`
    - `graphql` → `~> 2.5`
    - `httparty` → `~> 0.24`
    - `mini_magick` → `~> 5.2`
    - `mutex_m` → `~> 0.3`
    - `pg` → `~> 1.5`
    - `rack-cors` → `~> 2.0`
    - `redis` → `~> 5.4`
    - `resend` → `~> 1.0`
    - `rolify` → `~> 6.0`
    - `rollbar` → `~> 3.6`
    - `shakapacker` → `~> 9.7`
    - `simple_form` → `~> 5.3`
    - `turbo-rails` → `~> 2.0`
    - `validate_url` → `~> 1.0`
  - Dev/test gems similarly:
    - `byebug` → `~> 12.0`
    - `factory_bot_rails` → `~> 6.4`
    - `pry-byebug` → `~> 3.11`
    - `pry-rails` → `~> 0.3`
    - `better_errors` → `~> 2.10`
    - `binding_of_caller` → `~> 1.0`
    - `foreman` → `~> 0.88`
    - `letter_opener` → `~> 1.10`
    - `rubocop-capybara` → `~> 2.22`
    - `rubocop-factory_bot` → `~> 2.27`
    - `rubocop-graphql` → `~> 1.5`
    - `rubocop-rails` → `~> 2.32`
    - `rubocop-rspec` → `~> 3.6`
    - `rubocop-rspec_rails` → `~> 2.31`
    - `web-console` → `~> 4.2`
    - `cuprite` → `~> 0.17`
    - `database_cleaner-active_record` → `~> 2.2`
    - `graphiql-rails` → `~> 1.10`
  - Preserve existing `require: false` annotations
  - Preserve comments on `drb` and `mutex_m`
  - Run `bundle install` to verify lockfile doesn't change resolved versions

  **Patterns to follow:**
  - Gems already using `~>` in the Gemfile (e.g., `activeadmin ~> 3.3.0`, `puma ~> 7.0`)

  **Test scenarios:**
  - `bundle install` resolves to identical versions as before
  - No gem resolution conflicts

  **Verification:**
  - All production gems use `~>` constraints
  - `Gemfile.lock` resolved versions remain unchanged

- [x] **Unit 7: Remove GraphQL scaffolded test_field**

  **Goal:** Remove placeholder mutation field and unused schema registration

  **Requirements:** R7

  **Dependencies:** None

  **Files:**
  - Modify: `app/graphql/types/mutation_type.rb`
  - Modify: `app/graphql/church_resources_schema.rb`

  **Approach:**
  - Remove the `test_field` definition and its method from `MutationType`, leaving the class as an empty `Types::BaseObject` subclass
  - Remove `mutation(Types::MutationType)` from `ChurchResourcesSchema` to avoid graphql-ruby raising on an empty type
  - Keep the `mutation_type.rb` file with the empty class for future use

  **Test scenarios:**
  - GraphQL schema loads without error
  - No `testField` available in the schema
  - Query operations continue to work

  **Verification:**
  - `MutationType` has no fields
  - Schema does not register a mutation type

- [x] **Unit 8: Clean up resolved TODO tracking files**

  **Goal:** Remove TODO tracking files for resolved items

  **Requirements:** R8, R9

  **Dependencies:** Units 1-7

  **Files:**
  - Delete: `docs/todos/ci-postgres-host-env-var.md`
  - Delete: `docs/todos/deduplicate-layout-head.md`
  - Delete: `docs/todos/mailgun-env-fetch-crash.md` (already resolved)
  - Delete: `docs/todos/remove-corejs-polyfills.md`
  - Delete: `docs/todos/remove-expires-header.md`
  - Delete: `docs/todos/rss-cache-key-sanitization.md`
  - Delete: `docs/todos/tighten-gemfile-constraints.md`

  **Approach:**
  - Delete each file after its corresponding unit is complete
  - The Mailgun file can be deleted immediately as the fix was already shipped

  **Verification:**
  - `docs/todos/` directory is empty or removed

## System-Wide Impact

- **CI pipeline:** Unit 1 changes an env var in the test job — if any other CI step reads `POSTGRES_HOST`, it would break (verified: nothing else reads it)
- **Browser caching:** Unit 3 removes `Expires` header — `Cache-Control` already covers this, no behavior change for clients
- **JavaScript bundle size:** Unit 4 reduces bundle by ~80-120KB gzipped — positive performance impact
- **RSS feed caching:** Unit 5 prevents cache pollution — existing invalid-type cache entries will expire naturally (1 day TTL)
- **GraphQL API surface:** Unit 7 removes the `testField` mutation — this is scaffolding that should never have been used by clients
- **Gem resolution:** Unit 6 constrains future `bundle update` behavior — no change to currently resolved versions

## Risks & Dependencies

- **Polyfill removal risk (low):** If any application code relies on a polyfilled API not natively available in target browsers, it would break at runtime. Mitigated by the `defaults` browserslist targeting only modern ES2015+ browsers, and Turbo already requiring module support.
- **Gemfile constraint risk (low):** Pessimistic constraints at minor version could block a needed patch update if a gem's next release bumps minor version. This is the intended behavior — major bumps should be deliberate.
- **Layout partial risk (low):** If any view helper or JavaScript depends on head content ordering, the extraction could cause issues. Mitigated by preserving exact content and order.

## Sources & References

- TODO files: `docs/todos/*.md`
- Inline TODO: `app/graphql/types/mutation_type.rb:4`
- Dual asset pipeline learnings: `docs/solutions/best-practices/rails-upgrade-dual-asset-pipeline-patterns-2026-03-27.md`
