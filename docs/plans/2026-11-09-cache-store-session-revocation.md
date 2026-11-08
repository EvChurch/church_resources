# CacheStore concurrent session revocation repair

Scope: GHSA-2586-8ghr-69fj and explicit SameSite Lax (GHSA-gmj8-hvj3-49mw).
Base: 25714f1e06fd3304b2ffb6ebd838325dfa38d8c4. No dependency, backend,
login routing/UI, infrastructure or CI foundation change. Preserve PR #282.

## Inspect and plan

Rails 7.2.4 CacheStore find_session/write_session/delete_session and fallback
keys match the publisher 8.0 backport's affected methods. Adapt publisher commit
5bb5ec66ed8faaf590ffe1222d7a5eb6e9d050f5 using a narrowly scoped prepend:
record the loaded private ID on the request; before writing that same ID,
check both private and legacy keys in a fresh local-cache scope. Return false
when both disappeared so Rack does not resend the revoked cookie. Preserve
new sessions, reset_session rotation, expiry and legacy migration.

Fail boot visibly unless ActionPack is exactly 7.2.4 and upstream source matches;
any Rails upgrade must review/remove this shim. This is the publisher's
existence-check contract, not an atomic backend compare-and-write transaction.
Deletion between the check and cache write remains a narrower residual window.
Do not claim full linearizable revocation or cancellation of in-flight actions.

## Work and validation

1. Add synthetic middleware tests for load/logout/stale completion, read and
   write requests, request-local stale cache, direct backend revocation,
   no stale Set-Cookie, reuse, new sessions, rotation and legacy fallback.
2. Capture failing baseline results, apply guarded publisher adaptation,
   set production same_site: :lax, verify actual emitted cookies.
3. Run native frozen install, lint, full RSpec, both asset pipelines and
   synthetic production acceptance. Observe exact-head hosted checks/image.
4. Review entire diff and publisher adaptation; publish dedicated draft PR if
   validation is incomplete. HUMAN/source-security review is independent
   of dependency assessment #331. No merge or deploy. Inherited controlled
   security build requires exact running-image and read-only smoke closure
   after normal release; this source PR cannot close it.

## Reconciliation

Fresh open PRs #339/#331/#310/#298 update dependencies; #282 restores login UI.
Merged #286 changes dependency minimums for different older advisories;
it does not repair this race. Archived assessment #331 reproduces the issue
and remains assessment-only. No concurrent source repair identified.
CE skill unavailable: inspect/plan/work/review habits followed directly.

## Review and local results

Publisher advisories and the complete 8.0 patch were reviewed. The prepend
retains 7.2.4's own session lookup/write behavior; matching returned/original
IDs identifies a successful lookup without duplicating its fallback logic.
Version plus source SHA256 guards the exact reviewed upstream implementation.
A future Rails change intentionally blocks boot until reviewed. Fixed upstream
versions currently listed are 8.0.5.2 and 8.1.4.1; remove the shim only when a
supported selected upgrade includes this fix and the regressions still pass.

Baseline: seven synthetic middleware examples, three expected failures:
read overlap, write overlap and backend revocation each restored credentials.
After repair: ten focused examples pass, including guard failure tests and
legacy migration. Full suite: 71 examples, zero failures, 12 pre-existing
pending model stubs; real Chrome examples execute. Frozen Bundler/Yarn,
148-file RuboCop, Shakapacker and production Webpack/Sprockets pass. The
production acceptance now deletes actual private Redis session keys between
controller authentication and session commit, verifies old credentials stay
denied, checks actual SameSite=Lax, and independently reissues a session for
the existing deleted-user denial. Password login/logout request tests pass.

No active OmniAuth/SAML/OAuth provider or cross-site authentication flow was
found. SameSite=Lax preserves ordinary same-site password login and top-level
navigation; future cross-site POST/embedded authentication must review policy.
One additional backend existence lookup for surviving private sessions, or
two on misses/legacy fallback, is inherited from the publisher fix. Existing
Redis TLS VERIFY_NONE and unrelated dependency advisories remain out of scope.
Hosted exact-head checks/image and independent HUMAN source-security review
must be recorded on the dedicated PR. Deployment/running-runtime closure is
still held separately; neither local tests nor the source PR closes it.
