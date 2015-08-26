source 'https://rubygems.org'
source 'https://rails-assets.org'

gem 'rails', '4.2.1'
gem 'rails-i18n'
gem 'i18n-js'

gem 'pg', group: :postgres
gem 'mysql2', group: :mysql

gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'jbuilder', '~> 2.2.4'
gem 'sdoc', '~> 0.4.1', group: :doc

gem 'bcrypt', '~> 3.1.7'

gem 'haml'
gem 'bootstrap-sass', '~> 3.2.0.1'
gem 'bootswatch-rails'
gem 'sweetalert-rails'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
gem 'devise', '~> 3.4.1'
gem 'devise-i18n'
gem 'devise-async'
gem 'bootstrap_form'
gem 'font-kit-rails'
gem 'nprogress-rails'
gem 'font-awesome-rails', '~> 4.3.0.0'
gem 'rails-assets-growl'
gem "paperclip", "~> 4.2"
gem 'delayed_paperclip'
gem 'fog'
gem 'fog-aws'
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.7.14'
gem 'tiny-color-rails'
gem 'jquery-minicolors-rails'

gem 'twemoji-rails'

gem 'rickshaw-rails'

gem 'ruby-progressbar'

gem 'rails_admin'

gem 'sidekiq'
gem 'sinatra', require: false

gem 'questiongenerator', git: 'https://github.com/retrospring/questiongenerator.git'

gem 'sanitize'
gem 'redcarpet'

# OmniAuth and providers
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-tumblr'

# OAuth clients
gem 'twitter'
gem 'tumblr_client'

gem 'foreman'
gem 'redis'

# API
gem 'doorkeeper'
gem 'doorkeeper-i18n'
gem 'grape'
gem 'wine_bouncer'
gem 'grape-entity'
gem 'grape-msgpack'
gem 'grape-throttle', git: 'https://github.com/Retrospring/grape-throttle.git'

gem 'fake_email_validator'

gem 'rollbar'

group :development do
  # require spring 1.3.5 since shit's on fire on my local instance with 1.3.4 (Gem::LoadError)
  # gem 'spring', '~> 1.3.5'
  gem 'byebug'
  gem 'web-console'
  gem 'quiet_assets'
end

group :production, :test do
  gem 'unicorn'
end

group :development, :test do
  gem 'oauth2'
  gem 'rake'
  gem 'thin'
  gem 'rspec-rails', '~> 3.0.0'
  gem 'rspec-expectations'
  gem 'factory_girl_rails', require: false
  gem 'faker'
  gem 'capybara'
  gem 'poltergeist'
  gem 'simplecov', require: false
  gem 'simplecov-json', require: false
  gem 'simplecov-rcov', require: false
  gem 'database_cleaner'
  gem 'better_errors'
  gem "letter_opener" # Use this just in local test environments
end
