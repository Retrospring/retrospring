require "rpush/daemon"
require "rpush/daemon/store/active_record"
require "rpush/client/active_record"

redis_url = ENV.fetch("REDIS_URL") { APP_CONFIG["redis_url"] }

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
  Rpush.config.push = true
  Rpush::Daemon.store = Rpush::Daemon::Store::ActiveRecord.new
  Rpush::Daemon.common_init
  Rpush::Daemon::Synchronizer.sync

  at_exit do
    Rpush::Daemon::AppRunner.stop
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end
