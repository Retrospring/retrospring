return unless APP_CONFIG.dig(:hcaptcha, :enabled)

Hcaptcha.configure do |config|
  config.site_key = APP_CONFIG.dig(:hcaptcha, :site_key)
  config.secret_key = APP_CONFIG.dig(:hcaptcha, :secret_key)
end
