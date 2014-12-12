Rails.application.config.middleware.use OmniAuth::Builder do
  if APP_CONFIG['sharing']['twitter']['enabled']
    provider :twitter, APP_CONFIG['sharing']['twitter']['consumer_key'], APP_CONFIG['sharing']['twitter']['consumer_secret']
  end
end