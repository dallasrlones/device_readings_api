# syntax = docker/dockerfile:1

# Use the Ruby base image
ARG RUBY_VERSION=3.3.0
FROM ruby:$RUBY_VERSION-slim

# Set the working directory
WORKDIR /app

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git pkg-config

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install all gems, including development and test gems
RUN bundle install --jobs 4 && \
    rm -rf ~/.bundle/ /usr/local/bundle/ruby/*/cache /usr/local/bundle/ruby/*/bundler/gems/*/.git

# Copy the application code
COPY . .

# Precompile bootsnap code for faster boot times (if using bootsnap)
RUN bundle exec bootsnap precompile app/ lib/ || true

# Create a non-root user and change ownership of relevant directories
RUN useradd -m -s /bin/bash appuser && \
    chown -R appuser:appuser /app

# Switch to the non-root user
USER appuser

# Default command (will be overridden by docker-compose)
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
