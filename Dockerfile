# syntax=docker/dockerfile:1
# Production-style image for running Rentroll locally with docker compose.
FROM ruby:3.3.6-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libyaml-dev sqlite3 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /rails
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_PATH=/usr/local/bundle

COPY Gemfile Gemfile.lock ./
RUN bundle install && rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache

COPY . .
RUN SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile

EXPOSE 5112
ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "5112"]
