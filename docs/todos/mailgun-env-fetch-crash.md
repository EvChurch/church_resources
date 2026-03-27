---
title: Prevent boot crash when MAILGUN_API_KEY is missing
priority: p2
status: ready
source: code-review
---

# Prevent boot crash when MAILGUN_API_KEY is missing

`ENV.fetch('MAILGUN_API_KEY')` in `config/environments/production.rb` raises `KeyError` at boot if the env var is missing. This crashes console sessions, rake tasks, and migrations that don't need mailer functionality. Use `ENV['MAILGUN_API_KEY']` or provide a default.

**File:** `config/environments/production.rb:73`
