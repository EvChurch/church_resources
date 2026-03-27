---
title: "feat: Upgrade Ruby 3.4 + Rails 7.2 with dependency security audit"
type: feat
status: completed
date: 2026-03-27
origin: docs/brainstorms/2026-03-27-ruby-rails-upgrade-requirements.md
---

# Upgrade Ruby 3.4 + Rails 7.2 with Dependency Security Audit

## Overview

Upgrade the application from Ruby 3.2.10 + Rails 7.0.8.7 to Ruby 3.4 + Rails 7.2, replacing deprecated dependencies (turbolinks, sass-rails, koala), modernizing the test framework, and resolving security vulnerabilities. This upgrade happens on Heroku before the planned Railway migration (see origin: docs/brainstorms/2026-03-27-ruby-rails-upgrade-requirements.md).

## Problem Frame

The application runs outdated Ruby/Rails versions with several deprecated or unmaintained dependencies creating security exposure and blocking modern Rails features. The upgrade must be completed on the known Heroku platform before the Railway infrastructure migration to reduce compounding risk.

## Requirements Trace

- R1. Upgrade Ruby from 3.2.10 to 3.4
- R2. Upgrade Rails from 7.0 to 7.2, stepping through 7.1
- R3. Replace turbolinks with turbo-rails
- R4. Replace sass-rails with cssbundling-rails (Dart Sass)
- R5. Remove koala gem and initializer
- R6. Update rspec-rails from ~> 3.8 to 7.x
- R7. Update mechanize to latest
- R8. Tighten loose version constraints
- R9. Run bundle audit and resolve CVEs
- R10. CI pipeline passes on new versions

## Scope Boundaries

- **In scope:** Ruby/Rails upgrade, deprecated gem replacement, dependency security audit, CI updates
- **Out of scope:** Railway migration, new features, database schema changes, jQuery removal, ActiveAdmin major version changes
- **Out of scope:** `@rails/ujs` removal — keep it for now since views may use `data-remote` or `data-confirm` attributes; removing it is a separate task

## Context & Research

### Relevant Code and Patterns

**Dual asset pipeline:** The app runs Shakapacker (Webpack 5) for the main app AND Sprockets for ActiveAdmin assets only. `sass-rails` is used exclusively by Sprockets to compile `app/assets/stylesheets/active_admin.scss`. The main app SCSS goes through Webpack's sass-loader. This means replacing `sass-rails` requires a Sprockets-compatible Dart Sass gem (e.g., `dartsass-sprockets`), not `cssbundling-rails` which would bypass Sprockets entirely.

**Turbolinks usage is minimal:** Only used in `app/javascript/packs/application.js` (require + `turbolinks:load` event for video.js init) and two layout files (`data-turbolinks-track` attributes). Devise 4.9.4 has built-in Turbo support — no special configuration needed.

**`concurrent-ruby` pin:** Gemfile pins `concurrent-ruby` to 1.3.4 with comment "Fix for Rails 7.0 Logger compatibility". Rails 7.1+ resolves this — the pin can be removed.

**Config changes needed for Rails 7.1+:**
- `config.cache_classes` → `config.enable_reloading` (production.rb, development.rb)
- `show_exceptions = false` → `show_exceptions = :none` (test.rb)
- `to_formatted_s(:rfc822)` → `to_fs(:rfc822)` (production.rb)
- `config.load_defaults 7.0` → step to `7.1` then `7.2`
- `fixture_path` → `fixture_paths` (array) in spec/rails_helper.rb

### Institutional Learnings

No `docs/solutions/` directory exists. This is a greenfield upgrade — extra caution and incremental validation warranted.

## Key Technical Decisions

- **Step through Rails 7.1 first:** Rails 7.0 → 7.2 should go through 7.1 to catch deprecation warnings incrementally and isolate breakage. Update `load_defaults` to 7.1, fix issues, then to 7.2.
- **Use `dartsass-sprockets` instead of `cssbundling-rails`:** The brainstorm chose cssbundling-rails, but research reveals sass-rails is only used by Sprockets for ActiveAdmin. `dartsass-sprockets` is the correct drop-in replacement that keeps ActiveAdmin's Sprockets pipeline working. `cssbundling-rails` would require migrating ActiveAdmin assets out of Sprockets entirely — unnecessary complexity.
- **Keep `@rails/ujs` for now:** Turbo replaces much of UJS, but removing UJS requires auditing all views for `data-remote`, `data-confirm`, and `data-method` usage. Keep both temporarily; removal is a separate task.
- **Ruby upgrade after Rails upgrade:** Update Rails first (on Ruby 3.2), then bump Ruby to 3.4. This isolates Rails compatibility issues from Ruby compatibility issues.

## Open Questions

### Resolved During Planning

- **Q: Does ActiveAdmin 3.3 work with Rails 7.2?** Yes, ActiveAdmin 3.3.0 supports Rails 7.2.
- **Q: Does Devise 4.9.4 work with Turbo?** Yes, Devise 4.9+ has built-in Turbo support and automatically returns 422 for failed auth when turbo-rails is detected.
- **Q: What replaces sass-rails for Sprockets?** `dartsass-sprockets` — a drop-in replacement that uses Dart Sass with the Sprockets pipeline.

### Deferred to Implementation

- **Exact rspec-rails 7.x migration issues:** May surface additional deprecation warnings or config changes beyond `fixture_paths`. Fix as encountered.
- **`@rails/ujs` view audit:** Needed before eventual removal but out of scope for this upgrade.
- **ActiveAdmin FriendlyId monkey-patch:** The `after_load` patch in `config/initializers/active_admin.rb` (lines 316-326) should be smoke-tested but is unlikely to break.

## Implementation Units

### Phase 1: Rails 7.0 → 7.1

- [ ] **Unit 1: Remove koala and clean up dead dependencies**

  **Goal:** Remove unused gems and tighten loose constraints before the main upgrade.

  **Requirements:** R5, R7, R8

  **Dependencies:** None

  **Files:**
  - Modify: `Gemfile`
  - Delete: `config/initializers/koala.rb`
  - Regenerate: `Gemfile.lock`

  **Approach:**
  - Remove `koala` gem and delete its initializer
  - Update `mechanize` to `~> 2.17`
  - Tighten `capybara` to `~> 3.40`
  - Remove `concurrent-ruby` pin (will be resolved by Rails 7.1)
  - Run `bundle install` and verify no breakage

  **Patterns to follow:** Existing Gemfile constraint style (`~>` pessimistic constraints)

  **Test scenarios:**
  - `bundle install` succeeds
  - Existing test suite passes unchanged

  **Verification:** All tests green, no runtime errors referencing koala

- [ ] **Unit 2: Upgrade Rails to 7.1**

  **Goal:** Move from Rails 7.0.8.7 to latest Rails 7.1.x

  **Requirements:** R2

  **Dependencies:** Unit 1

  **Files:**
  - Modify: `Gemfile` (change `~> 7.0.0` to `~> 7.1.0`)
  - Modify: `config/application.rb` (`load_defaults 7.1`)
  - Modify: `config/environments/production.rb` (`cache_classes` → `enable_reloading`, `to_formatted_s` → `to_fs`)
  - Modify: `config/environments/development.rb` (`cache_classes` → `enable_reloading`)
  - Modify: `config/environments/test.rb` (`show_exceptions` boolean → symbol)
  - Regenerate: `Gemfile.lock`

  **Approach:**
  - Update rails constraint to `~> 7.1.0`
  - Run `bundle update rails` and let dependencies resolve
  - Apply known config changes (cache_classes, show_exceptions, to_formatted_s)
  - Run `rails app:update:configs` and selectively accept new defaults
  - Review and address any deprecation warnings

  **Patterns to follow:** Rails upgrade guide conventions

  **Test scenarios:**
  - Application boots in development
  - All existing tests pass
  - No deprecation warnings from removed/renamed config options
  - ActiveAdmin dashboard loads
  - Devise sign-in/sign-out works

  **Verification:** Full test suite green, app boots without deprecation errors

### Phase 2: Dependency Modernization

- [ ] **Unit 3: Replace sass-rails with dartsass-sprockets**

  **Goal:** Replace the deprecated Ruby Sass compiler with Dart Sass for Sprockets

  **Requirements:** R4

  **Dependencies:** Unit 2

  **Files:**
  - Modify: `Gemfile` (remove `sass-rails`, add `dartsass-sprockets`)
  - Modify: `app/assets/stylesheets/active_admin.scss` (if any `@import` syntax changes needed)
  - Regenerate: `Gemfile.lock`

  **Approach:**
  - Replace `sass-rails (~> 5)` with `dartsass-sprockets` in Gemfile
  - `dartsass-sprockets` is a drop-in for Sprockets SCSS compilation
  - Test that ActiveAdmin SCSS compiles correctly — the `@import` syntax used in `active_admin.scss` should work but Dart Sass has stricter rules
  - The main app SCSS (via Webpack sass-loader) is unaffected

  **Test scenarios:**
  - `rails assets:precompile` succeeds
  - ActiveAdmin pages render with correct styling
  - Main app styles unaffected

  **Verification:** ActiveAdmin dashboard renders correctly with all styles intact

- [ ] **Unit 4: Replace turbolinks with turbo-rails**

  **Goal:** Migrate from deprecated turbolinks to Hotwire Turbo

  **Requirements:** R3

  **Dependencies:** Unit 2

  **Files:**
  - Modify: `Gemfile` (remove `turbolinks`, add `turbo-rails`)
  - Modify: `package.json` (remove `turbolinks`, add `@hotwired/turbo-rails`)
  - Modify: `app/javascript/packs/application.js` (replace turbolinks require/start with Turbo import, change `turbolinks:load` → `turbo:load`)
  - Modify: `app/views/layouts/application.html.erb` (`data-turbolinks-track` → `data-turbo-track`)
  - Modify: `app/views/layouts/devise.html.erb` (same attribute change)
  - Regenerate: `Gemfile.lock`, `yarn.lock`

  **Approach:**
  - Swap gems and npm packages
  - In `application.js`: replace `require("turbolinks").start()` with `import "@hotwired/turbo-rails"` and change event listener from `turbolinks:load` to `turbo:load`
  - In layouts: change `data-turbolinks-track: 'reload'` to `data-turbo-track: 'reload'`
  - Devise 4.9.4 auto-detects turbo-rails — no initializer changes needed
  - The commented-out Turbolinks::Controller block in devise.rb can be removed

  **Test scenarios:**
  - Page navigation works (Turbo Drive replaces Turbolinks)
  - Video.js players initialize on page load and after navigation
  - Devise sign-in, sign-out, and failed auth work correctly
  - ActiveAdmin is unaffected (uses its own JS pipeline)

  **Verification:** Manual navigation test — pages load without full reload, video players work, auth flows complete

- [ ] **Unit 5: Update rspec-rails to 7.x**

  **Goal:** Modernize the test framework from 3.9.1 to latest 7.x

  **Requirements:** R6

  **Dependencies:** Unit 2

  **Files:**
  - Modify: `Gemfile` (change `~> 3.8` to `~> 7.0`)
  - Modify: `spec/rails_helper.rb` (`fixture_path` → `fixture_paths` array)
  - Regenerate: `Gemfile.lock`

  **Approach:**
  - Update rspec-rails constraint to `~> 7.0`
  - Run `bundle update rspec-rails` — this will also pull in rspec-core, rspec-expectations, rspec-mocks, rspec-support updates
  - Fix `fixture_path` → `fixture_paths` (singular string → array of strings)
  - Address any other deprecation warnings or breaking changes as they surface
  - The test suite is small (~13 spec files) so migration risk is manageable

  **Patterns to follow:** Existing spec structure and conventions

  **Test scenarios:**
  - All existing specs pass on rspec-rails 7.x
  - No deprecation warnings from rspec configuration
  - Feature specs with Cuprite still work

  **Verification:** `bundle exec rspec` passes with zero failures

### Phase 3: Rails 7.2 + Ruby 3.4

- [ ] **Unit 6: Upgrade Rails to 7.2**

  **Goal:** Move from Rails 7.1 to latest Rails 7.2.x

  **Requirements:** R2

  **Dependencies:** Units 2-5

  **Files:**
  - Modify: `Gemfile` (change `~> 7.1.0` to `~> 7.2.0`)
  - Modify: `config/application.rb` (`load_defaults 7.2`)
  - Regenerate: `Gemfile.lock`

  **Approach:**
  - Update rails constraint to `~> 7.2.0`
  - Run `bundle update rails`
  - Update `load_defaults` to 7.2
  - Run `rails app:update:configs` and review new defaults
  - Address any deprecation warnings or breaking changes

  **Test scenarios:**
  - Application boots
  - All tests pass
  - ActiveAdmin works
  - Devise auth flows work
  - Asset compilation succeeds (both Shakapacker and Sprockets)

  **Verification:** Full test suite green, app boots and serves pages

- [ ] **Unit 7: Upgrade Ruby to 3.4**

  **Goal:** Move from Ruby 3.2.10 to Ruby 3.4 (latest stable)

  **Requirements:** R1

  **Dependencies:** Unit 6

  **Files:**
  - Modify: `.ruby-version` (change to `3.4.x`)
  - Modify: `Gemfile` (update ruby version declaration)
  - Modify: `.github/workflows/main.yml` (update `RUBY_VERSION` env var)
  - Modify: `.devcontainer/Dockerfile` (update ruby-install target if needed)
  - Regenerate: `Gemfile.lock`

  **Approach:**
  - Update `.ruby-version` and Gemfile ruby declaration to latest 3.4.x
  - Run `bundle install` — resolve any gem incompatibilities
  - Update CI workflow to use new Ruby version
  - Update Devcontainer if it specifies a Ruby version
  - Run full test suite

  **Test scenarios:**
  - `bundle install` succeeds on Ruby 3.4
  - All tests pass
  - No keyword argument warnings or frozen string issues
  - Asset compilation works

  **Verification:** Full test suite green on Ruby 3.4

### Phase 4: Security Audit and CI

- [ ] **Unit 8: Security audit and final verification**

  **Goal:** Run bundle audit, resolve CVEs, verify CI pipeline

  **Requirements:** R9, R10

  **Dependencies:** Unit 7

  **Files:**
  - Modify: `Gemfile` (if any gems need version bumps for CVEs)
  - Modify: `.github/workflows/main.yml` (verify all jobs pass)
  - Regenerate: `Gemfile.lock`

  **Approach:**
  - Add `bundler-audit` gem if not present, or run `bundle audit` via CLI
  - Review all advisory results and bump affected gems
  - Push branch and verify all three CI jobs pass (lint, test, shakapacker)
  - Run `bundle outdated` for awareness of remaining upgradeable gems

  **Test scenarios:**
  - `bundle audit` reports zero vulnerabilities
  - All three CI jobs (lint, test, shakapacker) pass
  - Application deploys successfully to Heroku staging (if available)

  **Verification:** Clean `bundle audit`, green CI, app runs on Heroku

## System-Wide Impact

- **Interaction graph:** Turbo Drive replaces Turbolinks for all page navigation. Devise's failure app behavior changes (422 instead of 302 for Turbo). ActiveAdmin is isolated on its own asset pipeline and should be unaffected.
- **Error propagation:** Rails 7.1+ changes `show_exceptions` from boolean to symbol — test environment error handling changes.
- **State lifecycle risks:** Session storage (Redis) is unaffected. Cache store configuration is compatible.
- **API surface parity:** GraphQL endpoint is unaffected. Standard Rails routes continue working.
- **Integration coverage:** Feature specs with Cuprite cover ActiveAdmin. Request specs cover public pages. Manual verification needed for Devise auth flows with Turbo.

## Risks & Dependencies

- **Heroku stack compatibility:** Heroku-24 supports Ruby 3.4. Verify the app's current stack.
- **ActiveAdmin Sprockets dependency:** ActiveAdmin 3.3 requires Sprockets. The `dartsass-sprockets` swap must preserve this pipeline.
- **Dart Sass `@import` deprecation:** Dart Sass is deprecating `@import` in favor of `@use`. ActiveAdmin's SCSS uses `@import` heavily. This will emit warnings but still work — fixing it is out of scope.
- **rspec-rails major version jump:** Jumping from 3.x to 7.x is a large gap. The small test suite (~13 files) limits blast radius, but unexpected breakage is possible.
- **Bundle resolution:** Updating Rails + multiple gems simultaneously can cause dependency conflicts. The phased approach (Rails first, then deps, then Ruby) mitigates this.

## Sources & References

- **Origin document:** [docs/brainstorms/2026-03-27-ruby-rails-upgrade-requirements.md](docs/brainstorms/2026-03-27-ruby-rails-upgrade-requirements.md)
- Related plan: [docs/plans/2026-03-27-001-refactor-heroku-to-railway-migration-plan.md](docs/plans/2026-03-27-001-refactor-heroku-to-railway-migration-plan.md) (sequenced after this upgrade)
- Key files: `Gemfile`, `config/application.rb`, `app/javascript/packs/application.js`, `app/views/layouts/application.html.erb`
