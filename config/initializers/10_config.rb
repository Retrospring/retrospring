# Auxiliary config
APP_CONFIG = YAML.load_file(Rails.root.join('config', 'justask.yml'))

# Update rails config for mail
Rails.application.config.action_mailer.default_url_options = { host: APP_CONFIG['hostname'] }
