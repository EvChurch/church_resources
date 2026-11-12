FROM node:22.23.5-bookworm-slim@sha256:e9f565d32859f0cbfb52125eafe8be39390f24dac302dc3cdf566e8ba3ab21ee AS node-runtime
FROM ruby:3.4.12-bookworm@sha256:d7c312a48736dd291d7ce043c847f04dfde9bdf7334491ca6a545a4a184395be AS base

WORKDIR /app
COPY bin/security-update-ca /usr/local/bin/security-update-ca
RUN bash /usr/local/bin/security-update-ca \
    && apt-get install -y --no-install-recommends libbrotli1 libbrotli-dev imagemagick libpq-dev \
    && dpkg --compare-versions "$(dpkg-query -W -f='${Version}' libbrotli1)" ge 1.0.9-2+deb12u1 \
    && dpkg --compare-versions "$(dpkg-query -W -f='${Version}' libbrotli-dev)" ge 1.0.9-2+deb12u1 \
    && rm -rf /var/lib/apt/lists/*
ENV SSL_CERT_DIR=/usr/local/share/security-ca/certs

COPY --from=node-runtime /usr/local/bin/node /usr/local/bin/node
COPY --from=node-runtime /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node-runtime /opt/yarn-v1.22.22 /opt/yarn-v1.22.22
RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
    && ln -sf /opt/yarn-v1.22.22/bin/yarn /usr/local/bin/yarn \
    && node -e 'if (process.version !== "v22.23.5") process.exit(1)' \
    && gem install bundler -v 2.4.19 --no-document

ENV RAILS_ENV=production RACK_ENV=production \
    RAILS_SERVE_STATIC_FILES=true RAILS_LOG_TO_STDOUT=true \
    BUNDLE_WITHOUT=development:test BUNDLE_DEPLOYMENT=true

FROM base AS builder
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile
COPY . .
# Asset initialization needs an adapter and a storage service. Use local-only
# build settings, then remove the initializer before constructing the runtime.
RUN printf '%s\n' 'Rails.application.config.active_storage.service = :local' \
      > config/initializers/build_only_asset_storage.rb \
    && SECRET_KEY_BASE=build-only-placeholder \
    DATABASE_URL=postgresql://build:build@127.0.0.1/church_resources_build \
    yarn build \
    && rm config/initializers/build_only_asset_storage.rb
RUN rm -rf /root/.bundle /root/.gem /root/.cache /usr/local/bundle/cache

FROM base AS runtime
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
