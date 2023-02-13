# frozen_string_literal: true

return if Rails.env.test? # no need for the direct file store in testing

require "prometheus/client/data_stores/direct_file_store"

Rails.application.config.before_configuration do
  dir = Rails.root.join("tmp/prometheus_metrics")
  FileUtils.mkdir_p dir

  Prometheus::Client.config.data_store = Prometheus::Client::DataStores::DirectFileStore.new(dir:)
end

Rails.application.config.after_initialize do
  # ensure the version metric is populated
  Retrospring::Metrics::VERSION_INFO
end
