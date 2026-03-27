---
title: Sanitize resource_type param in RSS cache key
priority: p2
status: ready
source: code-review
---

# Sanitize resource_type param in RSS cache key

The RSS cache key includes `params[:resource_type]` before validation. If the param is present but not a valid `Resource::TYPES` key, the scope returns all resources but the cache key is type-specific, creating a separate cache entry for unfiltered results. Validate `resource_type` before including it in the cache key.

**File:** `app/controllers/resources_controller.rb:16`
