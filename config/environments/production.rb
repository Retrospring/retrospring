Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  config.asset_source = :sprockets

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  # config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = ENV.fetch("LOG_LEVEL") { "info" }.to_sym

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Better log formatting
  config.lograge.enabled = true

  # Use a different cache store in production.
  cache_redis_url = ENV.fetch("CACHE_REDIS_URL") { nil }
  if cache_redis_url.present?
    config.cache_store = :redis_cache_store, {
      url: cache_redis_url,
      pool_size: ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i,
      pool_timeout: ENV.fetch("CACHE_REDIS_TIMEOUT") { 5 },
      error_handler: -> (method:, returning:, exception:) {
        # Report errors to Sentry as warnings
        Sentry.capture_exception exception, level: 'warning',
                                 tags: { method: method, returning: returning }
      },
    }
  end

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "justask_#{Rails.env}"
  config.action_mailer.perform_caching = false

  config.action_mailer.default_options[:reply_to] = ENV['SMTP_REPLY_TO'] if ENV['SMTP_REPLY_TO'].present?
  config.action_mailer.default_options[:return_path] = ENV['SMTP_RETURN_PATH'] if ENV['SMTP_RETURN_PATH'].present?

  enable_starttls = nil
  enable_starttls_auto = nil

  case ENV['SMTP_ENABLE_STARTTLS']
  when 'always'
    enable_starttls = true
  when 'never'
    enable_starttls = false
  when 'auto'
    enable_starttls_auto = true
  else
    enable_starttls_auto = ENV['SMTP_ENABLE_STARTTLS_AUTO'] != 'false'
  end

  config.action_mailer.smtp_settings = {
    port: ENV['SMTP_PORT'],
    address: ENV['SMTP_SERVER'],
    user_name: ENV['SMTP_LOGIN'].presence,
    password: ENV['SMTP_PASSWORD'].presence,
    domain: ENV['SMTP_DOMAIN'] || ENV['LOCAL_DOMAIN'],
    authentication: ENV['SMTP_AUTH_METHOD'] == 'none' ? nil : ENV['SMTP_AUTH_METHOD'] || :plain,
    ca_file: ENV['SMTP_CA_FILE'].presence || '/etc/ssl/certs/ca-certificates.crt',
    openssl_verify_mode: ENV['SMTP_OPENSSL_VERIFY_MODE'],
    enable_starttls: enable_starttls,
    enable_starttls_auto: enable_starttls_auto,
    tls: ENV['SMTP_TLS'].presence && ENV['SMTP_TLS'] == 'true',
    ssl: ENV['SMTP_SSL'].presence && ENV['SMTP_SSL'] == 'true',
    read_timeout: 20,
  }

  config.action_mailer.delivery_method = ENV.fetch('SMTP_DELIVERY_METHOD', 'sendmail').to_sym

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = [I18n.default_locale]

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
