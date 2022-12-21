CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider => "Local",
    :local_root => "#{Rails.root}/public",
  }
  config.fog_directory = "/"

  unless APP_CONFIG["fog"].nil?
    config.fog_credentials = APP_CONFIG.dig("fog", "credentials") unless APP_CONFIG.dig("fog", "credentials").nil?
    config.fog_directory = APP_CONFIG.dig("fog", "directory") unless APP_CONFIG.dig("fog", "directory").nil?
  end
end

CarrierWave::Backgrounder.configure do |c|
  c.backend :sidekiq, queue: :carrierwave
end
