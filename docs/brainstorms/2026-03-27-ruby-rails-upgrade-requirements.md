---
date: 2026-03-27
topic: ruby-rails-upgrade-security-audit
---

# Ruby 3.4 + Rails 7.2 Upgrade & Dependency Security Audit

## Problem Frame

The application runs Ruby 3.2.10 and Rails 7.0.8.7 with several deprecated or unmaintained dependencies (turbolinks, sass-rails, koala). These create security exposure, block adoption of modern Rails features, and increase friction for future upgrades. The upgrade should be completed on Heroku **before** the planned Railway migration to reduce risk.

## Requirements

- R1. Upgrade Ruby from 3.2.10 to 3.4 (latest stable) across `.ruby-version`, `Gemfile`, CI config, and Devcontainer
- R2. Upgrade Rails from 7.0 to 7.2 (latest stable 7.2.x), stepping through 7.1 first if needed for smooth migration
- R3. Replace `turbolinks` with `turbo-rails` (Hotwire Turbo) — migrate all turbolinks references in views, JS, and layouts
- R4. Replace `sass-rails` with `cssbundling-rails` using Dart Sass — migrate SCSS pipeline to work with the new setup
- R5. Remove `koala` gem and its initializer (`config/initializers/koala.rb`) — no API calls exist; `facebook_url` fields are plain strings and unaffected
- R6. Update `rspec-rails` from ~> 3.8 to latest (7.x) and fix any resulting test breakage
- R7. Update `mechanize` to latest (2.17+)
- R8. Tighten loose version constraints (e.g., `capybara >= 2.15` → `~> 3.40`)
- R9. Run `bundle audit` and resolve any remaining CVEs in transitive dependencies
- R10. Ensure CI pipeline (GitHub Actions) passes on the new Ruby/Rails versions

## Success Criteria

- All tests pass on Ruby 3.4 + Rails 7.2
- `bundle audit` reports no known vulnerabilities
- No deprecated gems remain (turbolinks, sass-rails, koala removed)
- Application deploys and runs correctly on Heroku
- CI pipeline green on new versions

## Scope Boundaries

- **In scope:** Ruby/Rails upgrade, deprecated gem replacement, dependency security audit, CI updates
- **Out of scope:** Railway migration (sequenced after this upgrade), new feature work, database schema changes, ActiveAdmin major version upgrade (unless required for Rails 7.2 compat)
- **Out of scope:** jQuery removal — kept for now since ActiveAdmin and existing JS depend on it

## Key Decisions

- **Upgrade before Railway migration:** Reduces variables during infra migration by upgrading on the known Heroku platform first
- **Turbolinks → Turbo included:** Cleaning up the deprecated dependency now rather than carrying it into the new infrastructure
- **cssbundling-rails for CSS:** Leverages existing Node/shakapacker pipeline; Rails 7+ standard approach
- **Remove koala:** No active API usage found — only plain URL strings stored on events
- **Step through Rails 7.1:** Rails 7.0 → 7.2 should go through 7.1 first to catch deprecation warnings incrementally

## Dependencies / Assumptions

- Heroku stack supports Ruby 3.4 (Heroku-24 stack does)
- ActiveAdmin 3.3 is compatible with Rails 7.2 (or a minor bump is available)
- shakapacker 8.0 is compatible with Rails 7.2
- The test suite is the primary validation mechanism — assumed to have reasonable coverage

## Outstanding Questions

### Resolve Before Planning

(None — all product decisions resolved)

### Deferred to Planning

- [Affects R2][Needs research] Does Rails 7.1 → 7.2 require any ActiveAdmin configuration changes?
- [Affects R3][Needs research] How extensive is the turbolinks usage in views/JS? Estimate migration effort.
- [Affects R4][Needs research] How is the SCSS pipeline structured with shakapacker? Confirm cssbundling-rails integration path.
- [Affects R6][Technical] Will the rspec-rails 3.x → 7.x jump require changes to test helper configuration or shared examples?
- [Affects R2][Needs research] Are there any Rails 7.1/7.2 breaking changes that affect Devise, Rolify, or Draper?

## Next Steps

→ `/ce:plan` for structured implementation planning
