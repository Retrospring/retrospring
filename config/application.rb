require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
start = Time.now
Bundler.require(*Rails.groups)
puts 'processing time of bundler require: ' + "#{(Time.now - start).round(3).to_s.ljust(5, '0')}s".light_green

require_relative "../lib/version"

module Justask
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.load_defaults 6.0
    config.autoload_paths += %W["#{config.root}/app/validators"]

    # Use Sidekiq for background jobs
    config.active_job.queue_adapter = :sidekiq

    config.i18n.default_locale = "en"
    config.i18n.fallbacks = [I18n.default_locale]
    config.i18n.enforce_available_locales = false

    config.after_initialize do
      Dir.glob Rails.root.join('config/late_initializers/*.rb') do |f|
        require f
      end
    end
  end
end
