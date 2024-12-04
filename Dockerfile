# syntax = docker/dockerfile:1

# Base Ruby Image
ARG RUBY_VERSION=3.2.2
FROM ruby:$RUBY_VERSION-slim AS base

# Set working directory
WORKDIR /app

# Install base packages for development
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    yarn \
    curl && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set environment variables for development
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle"

# Copy Gemfile and Gemfile.lock for dependency installation
COPY Gemfile Gemfile.lock ./

# Install gems
RUN gem install bundler && bundle install

# Copy the application code (bind-mounted in docker-compose.yml)
COPY . .

# Ensure no server.pid is present, required for development
RUN mkdir -p tmp/pids && \
    rm -f tmp/pids/server.pid

# Expose Rails default port
EXPOSE 3000

# Default command
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
