# frozen_string_literal: true

# Auxiliary config

APP_CONFIG = {}.with_indifferent_access

# load yml config if it's present
justask_yml_path = Rails.root.join("config/justask.yml")
APP_CONFIG.merge!(YAML.load_file(justask_yml_path)) if File.exist?(justask_yml_path)

# load config from ENV where possible
env_config = {
  # The site name, shown everywhere
  site_name: ENV.fetch("SITE_NAME", nil),

  hostname:  ENV.fetch("HOSTNAME", nil),
}.compact
APP_CONFIG.merge!(env_config)

# Update rails config for mail
Rails.application.config.action_mailer.default_url_options = {
  host: APP_CONFIG["hostname"],
}
