# frozen_string_literal: true

source "https://rubygems.org"

gem "i18n-js", "3.9.2"
gem "rails", "~> 6.1"
gem "rails-i18n", "~> 6.0"

gem "pg"

gem "jbuilder", "~> 2.10"
gem "sass-rails", "~> 5.0"
gem "turbolinks", "~> 2.5.3"

gem "bcrypt", "~> 3.1.18"

gem "active_model_otp"
gem "bootsnap", require: false
gem "bootstrap_form"
gem "carrierwave", "~> 2.0"
gem "carrierwave_backgrounder", git: "https://github.com/mltnhm/carrierwave_backgrounder.git"
gem "colorize"
gem "devise", "~> 4.0"
gem "devise-async"
gem "devise-i18n"
gem "fog-aws"
gem "fog-core"
gem "fog-local"
gem "haml", "~> 5.0"
gem "hcaptcha", "~> 7.0"
gem "mini_magick"
gem "oj"
gem "paranoia"
gem "rqrcode"

gem "rolify", "~> 6.0"

gem "dry-initializer", "~> 3.1"
gem "dry-types", "~> 1.4"

gem "ruby-progressbar"

gem "pghero"
gem "rails_admin"
gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"

gem "sidekiq", "< 6" # remove version constraint once we have redis 5

gem "questiongenerator", "~> 1.0"

gem "httparty"
gem "redcarpet"
gem "sanitize"

# OmniAuth and providers
gem "omniauth"
gem "omniauth-twitter"

# OAuth clients
gem "twitter"
gem "twitter-text"

gem "redis"

gem "fake_email_validator"

gem "jwt", "~> 2.4"

group :development do
  gem "binding_of_caller"
  gem "byebug"
  gem "spring", "~> 4.0"
  gem "web-console", "~> 4.0"
end

gem "puma"

group :development, :test do
  gem "better_errors"
  gem "brakeman"
  gem "bullet"
  gem "capybara"
  gem "database_cleaner"
  gem "factory_bot_rails", require: false
  gem "faker"
  gem "guard-brakeman"
  gem "haml_lint", require: false
  gem "letter_opener" # Use this just in local test environments
  gem "poltergeist"
  gem "rails-controller-testing"
  gem "rake"
  gem "rspec-its", "~> 1.3"
  gem "rspec-mocks"
  gem "rspec-rails", "~> 5.1"
  gem "rspec-sidekiq", "~> 3.0", require: false
  gem "rubocop", "~> 1.22", ">= 1.22.1"
  gem "rubocop-rails", "~> 2.15"
  gem "shoulda-matchers", "~> 5.0"
  gem "simplecov", require: false
  gem "simplecov-cobertura", require: false
  gem "simplecov-json", require: false
end

group :production do
  gem "lograge"
end

gem "webpacker", "~> 5.2"

gem "omniauth-rails_csrf_protection", "~> 1.0"

gem "net-smtp"
gem "net-imap"
gem "net-pop"
