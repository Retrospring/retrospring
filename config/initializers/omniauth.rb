Rails.application.config.middleware.use OmniAuth::Builder do
  APP_CONFIG.fetch('sharing').each do |service, opts|
    if opts['enabled']
      provider service.to_sym, opts['consumer_key'], opts['consumer_secret']
    end
  end
end
