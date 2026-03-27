---
title: Tighten Gemfile version constraints
priority: p2
status: ready
source: code-review
---

# Tighten Gemfile version constraints

Mixed constraint styles: `>=` floor-only on devise/shakapacker/httparty/aws-sdk-s3 allows major version bumps. Unconstrained gems (turbo-rails, dartsass-sprockets, concurrent-ruby, mailgun-ruby) have no upper bound. Standardize on pessimistic `~>` constraints for all production gems.

**File:** `Gemfile`
