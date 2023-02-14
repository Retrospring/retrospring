# frozen_string_literal: true

require "prometheus/client/formats/text"

class MetricsController < ActionController::API
  include ActionController::MimeResponds

  def show
    fetch_sidekiq_metrics

    render plain: metrics
  end

  private

  SIDEKIQ_STATS_METHODS = %i[
    processed
    failed
    scheduled_size
    retry_size
    dead_size
    processes_size
  ].freeze

  def fetch_sidekiq_metrics
    stats = Sidekiq::Stats.new
    SIDEKIQ_STATS_METHODS.each do |key|
      Retrospring::Metrics::SIDEKIQ[key].set stats.public_send(key)
    end

    stats.queues.each do |queue, value|
      Retrospring::Metrics::SIDEKIQ[:queue_enqueued].set value, labels: { queue: }
    end
  end

  def metrics
    Prometheus::Client::Formats::Text.marshal(Retrospring::Metrics::PROMETHEUS)
  end
end
