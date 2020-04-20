redis_url = ENV.fetch("REDIS_URL") { APP_CONFIG["redis_url"] }

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end