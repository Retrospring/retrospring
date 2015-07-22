APP_CONFIG = YAML.load_file(Rails.root.join('config', 'justask.yml'))
Rails.application.config.action_mailer.default_url_options = { host: APP_CONFIG['hostname'] }
