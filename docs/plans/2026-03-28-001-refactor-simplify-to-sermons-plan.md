---
title: "refactor: Simplify app from Resources to Sermons"
type: refactor
status: active
date: 2026-03-28
origin: docs/brainstorms/2026-03-28-simplify-to-sermons-requirements.md
---

# Simplify App from Resources to Sermons

## Overview

Drop unused models (Location, Step, Event, Prayer, Service, Article), rename Resource to Sermon (removing STI), rename all join tables, and update all three surfaces (ActiveAdmin, public views, GraphQL API). 100 files affected: 62 to modify, 38 to delete. All 652 sermons and their relationships are preserved.

## Problem Frame

The app was built for multiple resource types and location-based content, but only sermons exist. The unused STI hierarchy, empty models, and dead admin/API surfaces add complexity without value. (see origin: docs/brainstorms/2026-03-28-simplify-to-sermons-requirements.md)

## Requirements Trace

- R1. Rename `resources` table to `sermons`, `Resource` model to `Sermon` (drop STI, remove `type` column)
- R2. Rename join tables: `resource_connection_*` → `sermon_*`
- R3. Drop tables: `steps`, `locations`, `location_events`, `location_prayers`, `location_services`, `location_connection_steps`
- R4. Remove all code for dropped entities
- R5. Update public views (keep `/resources` URL paths for link continuity)
- R6. Update ActiveAdmin: Sermon admin replaces Resource admin
- R7. Update GraphQL API: Sermon type/queries replace Resource
- R8. Preserve all sermon data and relationships
- R9. Keep users, roles, categories, topics, scriptures, series, authors unchanged

## Scope Boundaries

- 3 locations and 17 events are intentionally dropped
- Public URLs stay at `/resources` (not renamed to `/sermons`) for link continuity
- User/auth system unchanged
- No redirect mapping from old routes
- Categories, topics, scriptures, series, authors models unchanged — only their associations update

## Context & Research

### Relevant Code and Patterns

- `Resource` model (`app/models/resource.rb`) — STI base class with all logic; subtypes `Resource::Sermon` and `Resource::Article` are empty
- `Resource::Connection` module — uses `self.table_name_prefix = 'resource_connection_'` to map namespace to table names
- `ResourceTypeConstraint` (`app/constraints/resource_type_constraint.rb`) — validates `resource_type` param against `Resource::TYPES`; can be deleted entirely
- `ResourceDecorator` — `type_title` and `type_param` methods used extensively in views; simplify to static "Sermon" or remove
- Controllers (`resources_controller.rb`, `resources/authors_controller.rb`, etc.) — all query `Resource` with `Resource::TYPES` filtering
- Cache key in `resources_controller.rb` uses `params[:resource_type]` — needs simplification, not just renaming
- GraphQL mutations directory is empty (only `.keep`) — cleanup limited to query types and object definitions
- `active_storage_attachments.record_type` stores `'Resource'` — needs data migration to `'Sermon'`
- `friendly_id_slugs.sluggable_type` — needs data migration if slugs exist
- `active_admin_comments.resource_type` — ActiveAdmin's own polymorphic column, stores `'Resource::Sermon'`; needs update
- `roles` table has `resource_type`/`resource_id` — these are Rolify's own polymorphic columns, unrelated to our Resource model

### Institutional Learnings

- ActiveAdmin assets use Sprockets (not Shakapacker) — don't touch `active_admin.scss` when removing admin registrations
- GraphQL mutations are empty scaffolding — simplifies API cleanup

## Key Technical Decisions

- **Keep `/resources` URL paths**: Public URLs stay as `/resources` for link/SEO continuity. The controller and route names stay as `resources`, but internally they query `Sermon`. This means the controller is named `ResourcesController` but queries the `Sermon` model.
- **Use `rename_table` migrations**: PostgreSQL `rename_table` preserves indexes automatically. Foreign key constraints need manual verification/update in the migration.
- **Data migration for polymorphic types**: `active_storage_attachments.record_type`, `friendly_id_slugs.sluggable_type`, and `active_admin_comments.resource_type` all store class names as strings. These must be updated from `'Resource'`/`'Resource::Sermon'` to `'Sermon'` in the same migration.
- **Delete `ResourceTypeConstraint`**: No longer needed — only one type exists. Routes simplify.
- **Flatten `Sermon::Connection` namespace**: Rename join models from `Resource::Connection::Author` to `SermonAuthor` (flat, no namespace). Simpler than maintaining a connection module. Table names: `sermon_authors`, `sermon_scriptures`, `sermon_series`, `sermon_topics`.

## Open Questions

### Resolved During Planning

- **friendly_id slugs**: The `friendly_id_slugs` table is empty (0 rows), so no data migration needed for slugs. The `friendly_id` config on the model just needs to reference `Sermon` instead of `Resource`.
- **Migration strategy for foreign keys**: PostgreSQL `rename_table` handles indexes. Foreign keys referencing renamed tables need explicit `rename` in the migration since Rails `rename_table` doesn't auto-update FK references on other tables.
- **Public URL paths**: Keep `/resources` for link continuity (user decision).

### Deferred to Implementation

- **Exact cache key format after simplification**: The current cache key uses `resource_type` param. Determine final cache key during implementation after seeing how the controller simplifies.

## Implementation Units

- [ ] **Unit 1: Database migration — rename tables and update polymorphic types**

  **Goal:** Rename `resources` → `sermons`, rename all 4 join tables, drop 6 unused tables, remove `type` column, update polymorphic string references. (R1, R2, R3, R8)

  **Dependencies:** None — first step

  **Files:**
  - Create: `db/migrate/YYYYMMDD_simplify_resources_to_sermons.rb`
  - Auto-updated: `db/schema.rb`

  **Approach:**
  - Single migration with `rename_table` for each table rename
  - `remove_column :resources, :type` (after rename to `sermons`)
  - `drop_table` for: `steps`, `locations`, `location_events`, `location_prayers`, `location_services`, `location_connection_steps`
  - Update polymorphic string columns:
    - `active_storage_attachments` where `record_type = 'Resource'` → `'Sermon'`
    - `active_storage_blobs` — no change needed (no polymorphic type column)
    - `active_admin_comments` where `resource_type` contains `'Resource'` → update to `'Sermon'`
  - Update foreign key constraints that reference renamed tables
  - Migration must be reversible

  **Test scenarios:**
  - `sermons` table exists with all 652 rows, no `type` column
  - All 4 join tables renamed correctly with data intact
  - All 6 dropped tables no longer exist
  - `active_storage_attachments.record_type` all say `'Sermon'`
  - Foreign key constraints reference correct table names

  **Verification:**
  - `rails db:migrate` succeeds
  - `rails db:rollback` succeeds (reversibility)
  - Row counts match pre-migration counts

- [ ] **Unit 2: Models — rename Resource to Sermon, drop unused models**

  **Goal:** Create `Sermon` model, flatten join models, delete all location/step/article model files. (R1, R2, R4, R9)

  **Dependencies:** Unit 1

  **Files:**
  - Create: `app/models/sermon.rb` (from `app/models/resource.rb` content, drop STI)
  - Create: `app/models/sermon_author.rb` (flat, replaces `Resource::Connection::Author`)
  - Create: `app/models/sermon_scripture.rb`
  - Create: `app/models/sermon_series.rb`
  - Create: `app/models/sermon_topic.rb`
  - Modify: `app/models/author.rb`, `app/models/scripture.rb`, `app/models/series.rb`, `app/models/category/topic.rb` (update associations)
  - Delete: `app/models/resource.rb`, `app/models/resource/` directory (sermon.rb, article.rb, connection.rb, connection/*.rb)
  - Delete: `app/models/step.rb`, `app/models/location.rb`, `app/models/location/` directory
  - Test: `spec/models/sermon_spec.rb`

  **Approach:**
  - `Sermon` model: copy `Resource` logic, remove `self.inheritance_column`, remove `TYPES` constant, set `self.table_name = 'sermons'`
  - Flatten join models: `SermonAuthor` with `self.table_name = 'sermon_authors'`, simple `belongs_to :sermon` + `belongs_to :author`
  - Update association models: `Author`, `Scripture`, `Series`, `Category::Topic` — change `class_name: 'Resource::Connection::Author'` to `class_name: 'SermonAuthor'`, change `has_many :resources` to `has_many :sermons`

  **Patterns to follow:**
  - Existing `Resource` model for the Sermon model structure
  - Existing `Resource::Connection::Author` for join model pattern (simplify to flat)

  **Verification:**
  - `Sermon.count` returns 652
  - `Sermon.first.authors` returns associated authors
  - No `Resource` or `Location` or `Step` constants defined

- [ ] **Unit 3: Decorators and constraints — rename and clean up**

  **Goal:** Rename ResourceDecorator to SermonDecorator, delete article decorator, delete ResourceTypeConstraint. (R4, R5)

  **Dependencies:** Unit 2

  **Files:**
  - Create: `app/decorators/sermon_decorator.rb` (from resource_decorator.rb, simplify type methods)
  - Create: `app/decorators/sermon_scripture_decorator.rb` (from resource/connection/scripture_decorator.rb)
  - Delete: `app/decorators/resource_decorator.rb`, `app/decorators/resource/` directory
  - Delete: `app/constraints/resource_type_constraint.rb`

  **Approach:**
  - `SermonDecorator`: remove `type_title`/`type_param` methods or make them return static "Sermon"/"sermon"
  - Delete `ResourceTypeConstraint` — no longer needed with single type

  **Verification:**
  - `SermonDecorator` works for all existing decorator method calls in views
  - No references to `ResourceDecorator` or `ResourceTypeConstraint` remain

- [ ] **Unit 4: Controllers and routes — update to use Sermon model**

  **Goal:** Update controllers to query `Sermon` instead of `Resource`. Simplify routes (remove type constraint). Keep `/resources` URL paths. (R5)

  **Dependencies:** Unit 2, Unit 3

  **Files:**
  - Modify: `app/controllers/resources_controller.rb` (query `Sermon` instead of `Resource`, simplify cache key)
  - Modify: `app/controllers/resources/authors_controller.rb` (query `Sermon`)
  - Modify: `app/controllers/resources/scriptures_controller.rb`
  - Modify: `app/controllers/resources/series_controller.rb`
  - Modify: `app/controllers/resources/topics_controller.rb`
  - Modify: `config/routes.rb` (remove `ResourceTypeConstraint`, simplify resource routes)
  - Test: `spec/requests/resources_spec.rb`

  **Approach:**
  - Controllers stay named `ResourcesController` etc. (URL paths unchanged)
  - Replace `::Resource` queries with `::Sermon`
  - Remove `Resource::TYPES` references and type filtering logic
  - Simplify cache keys (remove `resource_type` param dependency)
  - Routes: remove `constraints: ResourceTypeConstraint.new` and `(:resource_type)` segments

  **Verification:**
  - `/resources` loads and shows sermons
  - `/resources/:id` shows a sermon
  - `/resources/authors`, `/resources/scriptures`, `/resources/series`, `/resources/topics` all work
  - RSS feed at `/resources.rss` works

- [ ] **Unit 5: Views — update templates to use Sermon**

  **Goal:** Update all view templates and partials to reference Sermon instead of Resource. Remove article/type-switching references. (R5)

  **Dependencies:** Unit 3, Unit 4

  **Files:**
  - Modify: All 22 view files in `app/views/resources/`, `app/views/shared/resource/`, `app/views/shared/`, `app/views/application/`, `app/views/pages/`
  - Key changes in: `home.html.erb`, `_listing_header.html.erb`, `_links.html.erb`, `_menu.html.erb`

  **Approach:**
  - Replace `Resource.published` with `Sermon.published`
  - Remove type-switching logic (`Resource.articles`, `Resource.sermons` → just `Sermon`)
  - Remove `resource_type` param references from navigation
  - Keep local variable names as `resource`/`resources` in partials if cleaner (avoid renaming every local var)
  - Simplify `_listing_header.html.erb` — remove article/sermon tabs since only sermons exist

  **Verification:**
  - Homepage loads with featured sermons
  - All browse-by pages (authors, scriptures, series, topics) render correctly
  - No "Article" references visible in the UI
  - Navigation links work

- [ ] **Unit 6: ActiveAdmin — replace Resource admin with Sermon admin**

  **Goal:** Create Sermon admin, delete all dropped model admin files. (R6)

  **Dependencies:** Unit 2

  **Files:**
  - Create: `app/admin/sermons.rb` (from `resource_sermons.rb`, register `Sermon` instead of `Resource::Sermon`)
  - Delete: `app/admin/resource_sermons.rb`, `app/admin/resource_articles.rb`
  - Delete: `app/admin/locations.rb`, `app/admin/location_events.rb`, `app/admin/location_services.rb`, `app/admin/location_prayers.rb`, `app/admin/location_connection_steps.rb`, `app/admin/steps.rb`

  **Approach:**
  - `ActiveAdmin.register Sermon` — copy permit_params and form/index/show configuration from `resource_sermons.rb`
  - Remove `Resource::Sermon` specific references
  - Don't touch `active_admin.scss` (Sprockets pipeline must stay intact)

  **Verification:**
  - `/admin/sermons` loads with all 652 sermons
  - Create/edit/delete sermon works
  - No admin pages for locations, steps, events, prayers, services, articles
  - ActiveAdmin CSS renders correctly (Sprockets intact)

- [ ] **Unit 7: GraphQL API — rename to Sermon types**

  **Goal:** Rename Resource GraphQL type/query to Sermon, remove all dropped model types/queries. (R7)

  **Dependencies:** Unit 2

  **Files:**
  - Create: `app/graphql/types/sermon_type.rb` (from `resource_type.rb`)
  - Create: `app/graphql/types/sermon_scripture_type.rb` (from `resource/connection/scripture_type.rb`)
  - Create: `app/graphql/queries/sermons_query.rb` (from `resources_query.rb`)
  - Modify: `app/graphql/types/query_type.rb` (rename `resources` field to `sermons`, remove `locations`, `events`, `prayers`, `steps` fields)
  - Delete: `app/graphql/types/resource_type.rb`, `app/graphql/types/resource/` directory
  - Delete: All location/step GraphQL types and queries (10 files)

  **Approach:**
  - `Types::SermonType` — rename fields, remove `Resource::Connection::ScriptureType` reference
  - `Queries::SermonsQuery` — query `::Sermon` instead of `::Resource`, remove `Resource::TYPES` filtering
  - Keep `ChurchResourcesSchema` class name (app name hasn't changed)

  **Verification:**
  - `{ sermons { nodes { id name } } }` query works
  - Introspection shows `Sermon` type, no `Resource`/`Location`/`Step` types
  - GraphiQL docs explorer shows updated schema

- [ ] **Unit 8: Tests — update specs and factories**

  **Goal:** Rename specs/factories for Sermon, delete specs for dropped models. (R8)

  **Dependencies:** Units 2-7

  **Files:**
  - Create: `spec/models/sermon_spec.rb`, `spec/factories/sermons.rb`
  - Create: `spec/models/sermon_author_spec.rb` (etc. for join models)
  - Create: `spec/factories/sermon_authors.rb` (etc.)
  - Modify: `spec/requests/resources_spec.rb` (update to use Sermon factory)
  - Modify: `spec/features/active_admin_smoke_spec.rb` (update paths, remove dropped model tests)
  - Delete: 12 spec/factory files for dropped models

  **Verification:**
  - Full test suite passes
  - No references to `Resource`, `Location`, `Step` in test files

## System-Wide Impact

- **Polymorphic type columns**: `active_storage_attachments.record_type` and `active_admin_comments.resource_type` store class name strings. Migration must update these atomically with the table rename.
- **Rolify `roles` table**: Has `resource_type`/`resource_id` columns but these are Rolify's own polymorphic system, unrelated to our Resource model. No change needed.
- **Cache invalidation**: Controller cache keys reference `resource_type` params. After simplification, cached pages with old keys will naturally expire. No explicit cache purge needed.
- **Active Storage**: Attachments link via `record_type: 'Resource'`. After data migration to `'Sermon'`, all existing file references continue working (S3 keys unchanged).
- **GraphQL API consumers**: The `resources` query field renames to `sermons`. This is a breaking API change. If external consumers exist, they need notification.

## Risks & Dependencies

| Risk | Severity | Mitigation |
|---|---|---|
| Migration fails on production data | High | Test migration against production data dump locally first. Ensure reversibility. |
| Polymorphic type mismatch after rename | High | Update ALL polymorphic `record_type`/`resource_type` columns in the same migration. |
| GraphQL breaking change for API consumers | Medium | Verify if any external apps consume the API before deploying. |
| ActiveAdmin asset breakage | Low | Don't touch `active_admin.scss`. Only modify Ruby registration files. |

## Sources & References

- **Origin document:** [docs/brainstorms/2026-03-28-simplify-to-sermons-requirements.md](docs/brainstorms/2026-03-28-simplify-to-sermons-requirements.md)
- Related code: `app/models/resource.rb`, `app/models/resource/`, `app/models/location/`, `app/admin/`, `app/graphql/`, `app/controllers/resources_controller.rb`
- Rails guide: `rename_table` preserves indexes in PostgreSQL
