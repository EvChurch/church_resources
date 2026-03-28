---
date: 2026-03-28
topic: simplify-to-sermons
---

# Simplify App to Sermons-Only

## Problem Frame

The app (resources.ev.church) was built to support multiple resource types (sermons, articles) and location-based content (events, prayers, services, steps). In practice, only sermons exist (652 records). The unused models, admin panels, API types, and STI hierarchy add complexity without value. Simplifying to a sermons-focused app reduces cognitive load, code surface, and maintenance burden.

## Requirements

- R1. Rename `resources` table to `sermons` and `Resource` model to `Sermon` (drop STI, remove `type` column)
- R2. Rename all join tables: `resource_connection_authors` → `sermon_authors`, `resource_connection_scriptures` → `sermon_scriptures`, `resource_connection_series` → `sermon_series`, `resource_connection_topics` → `sermon_topics`
- R3. Drop tables: `steps`, `locations`, `location_events`, `location_prayers`, `location_services`, `location_connection_steps`
- R4. Remove all models, admin resources, controllers, views, decorators, and GraphQL types for dropped entities (Location, Location::Event, Location::Prayer, Location::Service, Step, Resource::Article)
- R5. Update public views: rename resource references to sermon (routes, controllers, view templates, partials)
- R6. Update ActiveAdmin: replace Resource admin with Sermon admin, remove dropped model admin pages
- R7. Update GraphQL API: rename Resource type/queries to Sermon, remove dropped types/queries (locations, events, prayers, services, steps)
- R8. Preserve all existing sermon data and relationships (authors, categories, topics, scriptures, series, attachments)
- R9. Keep users, roles, categories, topics, scriptures, series, and authors unchanged

## Success Criteria

- All 652 sermons accessible with their relationships intact
- No references to Resource, Location, Step, Prayer, Service, Event, or Article in application code
- Admin, public views, and GraphQL API all use "Sermon" terminology
- All migrations are reversible

## Scope Boundaries

- 3 locations and 17 events are intentionally dropped (no data preservation needed)
- User/auth system unchanged
- No URL redirect mapping from old routes (clean break)
- Categories, topics, scriptures, series, authors models unchanged (only their relationship to Resource→Sermon changes)

## Key Decisions

- **Flat Sermon model (no STI)**: Since only sermons exist, drop the Resource parent class and type column entirely. Simpler model, simpler queries.
- **Rename tables via migration**: Rename rather than drop+recreate to preserve data and UUIDs.
- **Drop all location-related models**: Zero public usage, minimal data (all droppable).

## Outstanding Questions

### Deferred to Planning

- [Affects R1][Technical] Should `friendly_id` slugs be regenerated for sermons, or keep existing slug behavior?
- [Affects R5][Technical] Should public URLs change from `/resources` to `/sermons`, or keep `/resources` for SEO continuity?
- [Affects R2][Technical] Determine exact migration strategy for renaming tables while preserving foreign keys and indexes

## Next Steps

→ `/ce:plan` for structured implementation planning
