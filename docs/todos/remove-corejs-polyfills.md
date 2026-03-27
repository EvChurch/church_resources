---
title: Remove core-js and regenerator-runtime polyfills
priority: p3
status: ready
source: code-review
---

# Remove core-js and regenerator-runtime polyfills

`core-js/stable` and `regenerator-runtime` polyfill ES2015+ for IE11-era browsers. Turbo-rails requires ES module support, so these add ~80-120KB gzipped for zero benefit. Remove them and tighten the browserslist target.

**Files:** `app/javascript/packs/application.js:6-7`, `package.json`
