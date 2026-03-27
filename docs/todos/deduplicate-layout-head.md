---
title: Extract shared head content from application/devise layouts
priority: p2
status: ready
source: code-review
---

# Extract shared head content from application/devise layouts

`application.html.erb` and `devise.html.erb` have nearly identical `<head>` sections (meta tags, Font Awesome, pack tags). Changes must be applied in lockstep. Extract shared head content into a partial.

**Files:** `app/views/layouts/application.html.erb`, `app/views/layouts/devise.html.erb`
