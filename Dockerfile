FROM node:22.23.4-bookworm-slim@sha256:de170b39439eb0e5a3444ad7d60b015614a381e10fecae2e30ec9e735122f38d AS node-runtime
FROM ruby:3.4.11-bookworm@sha256:1aed73d35b66ce974febaefe42e8385abb8cbf6244ea4f45b266be9178acfd37 AS base

WORKDIR /app
COPY bin/security-update-ca /usr/local/bin/security-update-ca
RUN bash /usr/local/bin/security-update-ca \
    && apt-get install -y --no-install-recommends imagemagick libpq-dev \
    && rm -rf /var/lib/apt/lists/*
ENV SSL_CERT_DIR=/usr/local/share/security-ca/certs

COPY --from=node-runtime /usr/local/bin/node /usr/local/bin/node
COPY --from=node-runtime /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node-runtime /opt/yarn-v1.22.22 /opt/yarn-v1.22.22
RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
    && ln -sf /opt/yarn-v1.22.22/bin/yarn /usr/local/bin/yarn \
    && node -e 'if (process.version !== "v22.23.4") process.exit(1)' \
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
RUN SECRET_KEY_BASE=build-only-placeholder yarn build
RUN rm -rf /root/.bundle /root/.gem /root/.cache /usr/local/bundle/cache

FROM base AS runtime
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
