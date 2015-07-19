APP_CONFIG = YAML.load_file(Rails.root.join('config', 'justask.yml'))
APP_CONFIG["gif"] = {"header" => false, "avatar" => false} if APP_CONFIG["gif"].nil? # zero risk
