# frozen_string_literal: true

module Retrospring
  module Config
    module_function

    def config_hash = {}.with_indifferent_access.tap do |hash|
      # load yml config if it's present
      justask_yml_path = Rails.root.join("config/justask.yml")
      hash.merge!(YAML.load_file(justask_yml_path)) if File.exist?(justask_yml_path)

      # load config from ENV where possible
      env_config = {
        # The site name, shown everywhere
        site_name: ENV.fetch("SITE_NAME", nil),
      }.compact
      hash.merge!(env_config)

      # Update rails config for mail
      Rails.application.config.action_mailer.default_url_options = {
        host: hash["hostname"],
      }
    end

    def registrations_enabled? = APP_CONFIG.dig(:features, :registration, :enabled)

    def advanced_frontpage_enabled? = APP_CONFIG.dig(:features, :advanced_frontpage, :enabled)
  end
end
