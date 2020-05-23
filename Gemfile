# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 5.2'
gem 'rails-i18n', '~> 5.0'
gem 'i18n-js', '~> 3.6'

gem 'pg'

gem 'sass-rails', '~> 5.0'
gem 'webpacker', '~> 5.1', '>= 5.1.1'
gem 'coffee-rails', '~> 4.1'
gem 'turbolinks', '~> 5.2.0'
gem 'jbuilder', '~> 2.10'

gem 'bcrypt', '~> 3.1.7'

gem 'haml', '~> 5.0'
gem 'devise', '~> 4.0'
gem 'devise-i18n'
gem 'devise-async'
gem 'bootstrap_form'
gem "paperclip", "~> 5.2"
gem 'delayed_paperclip'
gem 'fog-core'
gem 'fog-aws'
gem 'fog-local'
gem 'colorize'

gem "rolify", "~> 5.2"

source "https://rails-assets.org" do
  gem 'rails-assets-growl'
end

gem 'ruby-progressbar'

gem 'rails_admin'
gem 'pghero'
gem 'newrelic_rpm'

gem 'sidekiq', "< 6" # remove version constraint once we have redis 5

gem 'questiongenerator', git: 'https://github.com/retrospring/questiongenerator.git'

gem 'sanitize'
gem 'redcarpet'
gem 'httparty'

# OmniAuth and providers
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-tumblr'

# OAuth clients
gem 'twitter'
# To use a more recent Faraday version, a fork of this gem is required.
gem 'tumblr_client', git: 'https://github.com/amplifr/tumblr_client'

gem 'foreman'
gem 'redis'

gem 'fake_email_validator'

group :development do
  gem 'spring', '~> 2.0'
  gem 'byebug'
  gem 'web-console', '< 4.0.0'
end

group :production do
  gem 'unicorn', group: :production
end

group :development, :test do
  gem 'rake'
  gem 'puma'
  gem 'rspec-rails', '~> 3.9'
  gem 'rspec-its', '~> 1.3'
  gem "rspec-sidekiq", "~> 3.0", require: false
  gem 'factory_bot_rails', require: false
  gem 'faker'
  gem 'capybara'
  gem 'poltergeist'
  gem 'simplecov', require: false
  gem 'simplecov-json', require: false
  gem 'simplecov-cobertura', require: false
  gem 'database_cleaner'
  gem 'better_errors'
  gem 'letter_opener' # Use this just in local test environments
  gem 'brakeman'
  gem 'guard-brakeman'
  gem 'timecop'
  gem 'rails-controller-testing'
  gem 'haml_lint', require: false
end
