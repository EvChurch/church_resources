# Controlled security build

The serving Ruby and Node distributions are patched, but the managed Railpack
builder still accepts the affected certificate chains before application hooks
execute. Build from pinned Ruby 3.4.11 and Node 22.23.4 images, filter the OS CA
store before Bundler or Yarn downloads, and retain the existing application,
lockfiles, asset commands and dashboard start command.

The production-image CI job builds without credentials and tests the copied
runtime versions, both affected chains and valid public TLS controls. Existing
RuboCop, RSpec and Shakapacker jobs remain required. No Rails integration, mail,
upload or synchronization is invoked by the trust probe.

Do not merge until all checks pass. After the normal main source release,
measure the exact running image and its effective clients and complete the
read-only application smoke before closing the audit row. Local Docker and Ruby
are unavailable; actual image validation must pass in hosted CI.
