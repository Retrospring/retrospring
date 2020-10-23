# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 5.2'
gem 'rails-i18n', '~> 5.0'
gem 'i18n-js', '= 3.0.0.rc10'

gem 'pg'

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1'
gem 'jquery-rails'
gem 'turbolinks', '~> 2.5.3'
gem 'jquery-turbolinks'
gem 'jbuilder', '~> 2.10'

gem 'bcrypt', '~> 3.1.7'

gem 'haml', '~> 5.0'
gem 'bootstrap', '~> 4.4', '>= 4.4.1'
gem 'sweetalert-rails'
gem 'devise', '~> 4.0'
gem 'devise-i18n'
gem 'devise-async'
gem 'active_model_otp'
gem 'rqrcode'
gem 'bootstrap_form'
gem 'font-kit-rails'
gem 'nprogress-rails'
gem 'font-awesome-rails', '~> 4.7.0'
gem 'fog-core'
gem 'fog-aws'
gem 'fog-local'
gem 'momentjs-rails', '>= 2.9.0'
gem 'moment-timezone-rails', '~> 1.0'
gem 'bootstrap4-datetime-picker-rails'
gem 'tiny-color-rails'
gem 'jquery-minicolors-rails'
gem 'colorize'
gem 'carrierwave', '~> 2.0'
gem 'carrierwave_backgrounder', git: 'https://github.com/mltnhm/carrierwave_backgrounder.git'
gem 'mini_magick'
gem "hcaptcha", "~> 6.0", git: "https://github.com/Retrospring/hcaptcha.git", ref: "v6.0.2"

gem "rolify", "~> 5.2"

source "https://rails-assets.org" do
  gem 'rails-assets-growl'
  gem 'rails-assets-jquery', '~> 2.2.0'
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

gem 'redis'

gem 'fake_email_validator'

group :development do
  gem 'spring', '~> 2.0'
  gem 'byebug'
  gem 'web-console', '< 4.0.0'
  gem 'binding_of_caller'
end

gem 'puma'

group :development, :test do
  gem 'rake'
  gem 'rspec-mocks'
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
