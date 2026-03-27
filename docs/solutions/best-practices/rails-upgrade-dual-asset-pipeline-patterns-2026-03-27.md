---
title: Rails upgrade patterns for dual asset pipeline apps
date: 2026-03-27
category: best-practices
module: asset-pipeline
problem_type: best_practice
component: development_workflow
symptoms:
  - "cssbundling-rails chosen as sass-rails replacement would bypass Sprockets and break ActiveAdmin"
  - "Ruby 3.4 removed mutex_m and drb from stdlib causing LoadError at boot"
  - "video.js players leaked on Turbo navigation due to missing disposal"
  - "data-setup attribute caused double-init race with manual turbo:load initialization"
root_cause: config_error
resolution_type: dependency_update
severity: medium
rails_version: 7.2.3
related_components:
  - hotwire_turbo
  - tooling
tags:
  - rails-upgrade
  - asset-pipeline
  - sprockets
  - shakapacker
  - dartsass-sprockets
  - ruby-3-4
  - activeadmin
  - turbo
  - video-js
---

# Rails upgrade patterns for dual asset pipeline apps

## Problem

Upgrading a Rails app from Ruby 3.2 + Rails 7.0 to Ruby 3.4 + Rails 7.2 required navigating multiple interrelated breaking changes: a deprecated Sass gem in a dual-pipeline asset setup, Ruby stdlib removals, Turbo event lifecycle changes with video.js player leaks, and renamed Rails configuration options.

## Symptoms

- `LoadError: cannot load such file -- mutex_m` at boot after upgrading to Ruby 3.4
- `bundle audit` CVEs from outdated `sassc` native extension in `sass-rails`
- video.js players leaking DOM nodes and event listeners on Turbo page navigation
- `turbolinks:load` event handlers silently stop firing after turbolinks-to-turbo migration
- Rails boot warnings from `config.cache_classes`, `show_exceptions = false`, `fixture_path` (singular)

## What Didn't Work

The initial brainstorm selected `cssbundling-rails` to replace the deprecated `sass-rails` gem. This was wrong because `cssbundling-rails` compiles CSS outside of Sprockets entirely -- it runs a standalone `sass` CLI and drops output into `app/assets/builds/`.

The app has **two** asset pipelines:
- **Shakapacker (Webpack 5)** handles main application SCSS via npm `sass` and `sass-loader`
- **Sprockets** handles only ActiveAdmin assets (`app/assets/stylesheets/active_admin.scss`)

Switching to `cssbundling-rails` would have broken ActiveAdmin's Sprockets-based asset compilation because ActiveAdmin's `stylesheet_link_tag` expects Sprockets to serve the compiled CSS, and `cssbundling-rails` does not integrate with Sprockets at all.

## Solution

### 1. sass-rails replacement (Sprockets-compatible Dart Sass)

```ruby
# Before
gem 'sass-rails', '~> 5'

# After
gem 'dartsass-sprockets'
```

`dartsass-sprockets` is a drop-in replacement that plugs Dart Sass into the Sprockets pipeline, so `active_admin.scss` continues to be compiled and served by Sprockets exactly as before.

### 2. Ruby 3.4 stdlib gem additions

```ruby
# Gemfile — these were default gems in Ruby 3.2 but removed in 3.4
gem 'drb'     # Required: removed from Ruby 3.4 stdlib
gem 'mutex_m' # Required: removed from Ruby 3.4 stdlib
```

### 3. video.js + Turbo lifecycle fix

```javascript
// Dispose players before Turbo caches the page
document.addEventListener('turbo:before-cache', function() {
  Object.keys(videojs.getPlayers()).forEach(function(id) {
    var player = videojs.getPlayers()[id];
    if (player) player.dispose();
  });
});

// Initialize on turbo:load with config from data attribute
document.addEventListener('turbo:load', function() {
  document.querySelectorAll('.video-js').forEach(function(el) {
    var config = JSON.parse(el.getAttribute('data-player-config') || '{}');
    videojs(el, config);
  });
});
```

In templates, replace `data-setup` with `data-player-config` to prevent video.js auto-init from racing with the manual `turbo:load` initialization.

### 4. Rails config renames (7.0 to 7.2)

```ruby
# config/environments/production.rb & development.rb
config.cache_classes = true      # Before
config.enable_reloading = false  # After (inverted boolean)

# config/environments/test.rb
config.action_dispatch.show_exceptions = false  # Before
config.action_dispatch.show_exceptions = :none  # After (symbol)

# config/environments/production.rb
'Expires' => 1.year.from_now.to_formatted_s(:rfc822)  # Before
'Expires' => 1.year.from_now.to_fs(:rfc822)           # After

# spec/rails_helper.rb
config.fixture_path = '...'    # Before (string)
config.fixture_paths = ['...'] # After (array)
```

Also: remove any `concurrent-ruby` version pin that was only needed for Rails 7.0 Logger compatibility.

## Why This Works

- **dartsass-sprockets** registers a Dart Sass compiler as a Sprockets preprocessor for `.scss` files, maintaining the exact same Sprockets asset serving contract that ActiveAdmin expects. It replaces the deprecated LibSass C binding with the actively maintained Dart Sass implementation without changing the pipeline architecture.
- **mutex_m and drb** were extracted from Ruby's default gems in 3.4. Rails 7.2 and its dependencies still require them, so they must be declared explicitly.
- **turbo:before-cache** fires before Turbo snapshots the page DOM for its cache. Disposing video.js players at that point tears down internal state, removes injected DOM elements, and detaches event listeners -- preventing leaks when Turbo restores a cached page. Removing `data-setup` eliminates the race where video.js auto-initializes before the `turbo:load` handler runs.
- **Config renames** align with Rails 7.1/7.2 deprecation cycles where boolean values were replaced with more expressive symbols or inverted naming.

## Prevention

1. **Audit asset pipeline topology before choosing CSS tooling.** Run `bundle exec rake assets:precompile --trace` to see which processors handle which files. Grep for `stylesheet_link_tag` vs `stylesheet_pack_tag` to identify which pipeline serves each set of styles.

2. **Check Ruby changelog for stdlib extractions before upgrading.** Run `ruby -e "require 'mutex_m'"` with the new Ruby to verify before deploying.

3. **Add a Turbo navigation integration test** that navigates away from and back to a page with video.js players, then asserts no duplicate elements or JS errors.

4. **Run `rails app:update` during major upgrades** to generate a config diff against the new Rails version's defaults.

5. **Pin a `bundle audit` check in CI** to flag CVEs early, creating pressure to migrate before the upgrade becomes urgent.

6. **When an app has multiple asset pipelines, document which pipeline owns which directory** in a Gemfile comment or project docs, so future maintainers don't accidentally swap one pipeline's tooling for another's.

## Related Issues

- [Upgrade plan](../plans/2026-03-27-002-feat-ruby-rails-upgrade-plan.md) (status: completed)
- [Upgrade requirements](../brainstorms/2026-03-27-ruby-rails-upgrade-requirements.md)
- [Railway migration plan](../plans/2026-03-27-001-refactor-heroku-to-railway-migration-plan.md) (sequenced after this upgrade)
