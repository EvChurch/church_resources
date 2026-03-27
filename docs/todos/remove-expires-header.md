---
title: Remove stale Expires header from production config
priority: p3
status: ready
source: code-review
---

# Remove stale Expires header from production config

`1.year.from_now.to_fs(:rfc822)` is evaluated once at boot and becomes stale over time. The `Cache-Control` max-age header on the same line already handles browser caching correctly. Remove the Expires header.

**File:** `config/environments/production.rb:28`
