Rails.application.config.middleware.use OmniAuth::Builder do
  %w(facebook twitter tumblr).each do |service|
    if APP_CONFIG['sharing'][service]['enabled']
      provider service.to_sym, APP_CONFIG['sharing'][service]['consumer_key'], APP_CONFIG['sharing'][service]['consumer_secret']
    end
  end
end