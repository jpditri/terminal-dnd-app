# frozen_string_literal: true

source 'https://rubygems.org'

ruby '>= 3.3.0'

# Rails
gem 'rails', '~> 7.1.0'
gem 'sprockets-rails'
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'importmap-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'jbuilder'
gem 'redis', '>= 4.0.1'
gem 'bcrypt', '~> 3.1.7'
gem 'bootsnap', require: false

# Authentication
gem 'devise', '~> 4.9'

# Soft deletes and audit trail
gem 'discard', '~> 1.3'
gem 'paper_trail', '~> 15.1'

# AI Integration
gem 'anthropic', '~> 0.1'  # Claude API
gem 'ruby-openai', '~> 6.0' # OpenAI fallback

# Discord Integration
gem 'discordrb', '~> 3.5'
gem 'discordrb-webhooks', '~> 3.5'

# Background jobs
gem 'sidekiq', '~> 7.0'

# JSON handling
gem 'oj', '~> 3.16'
gem 'multi_json', '~> 1.15'

# Feature flags
gem 'flipper', '~> 1.2'
gem 'flipper-active_record', '~> 1.2'

# Utilities
gem 'hashie', '~> 5.0'

# Markdown rendering
gem 'redcarpet', '~> 3.6'

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'rspec-rails', '~> 6.1'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.2'
  gem 'dotenv-rails', '~> 2.8'
end

group :development do
  gem 'web-console'
  gem 'rack-mini-profiler'
  gem 'spring'
  gem 'annotate'
  gem 'bullet'
end

group :test do
  gem 'capybara'
  gem 'cuprite'  # Headless Chrome driver for Capybara
  gem 'selenium-webdriver'  # Fallback driver
  gem 'webmock'
  gem 'vcr'
  gem 'shoulda-matchers'
  gem 'database_cleaner-active_record'
end
