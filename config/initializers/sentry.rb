Sentry.init do |config|
  config.release = Retrospring::Version.to_s

  config.dsn = APP_CONFIG[:sentry_dsn]
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set tracesSampleRate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production
  config.traces_sample_rate = 0.25

  config.before_send do |event, hint|
    if hint[:exception].is_a?(Errors::Base)
      # These are used for user-facing errors, not when something goes wrong
      nil
    end

    event
  end
end
