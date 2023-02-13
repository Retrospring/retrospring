# frozen_string_literal: true

require "prometheus/client/formats/text"

class MetricsController < ActionController::API
  include ActionController::MimeResponds

  def show
    render plain: metrics
  end

  private

  def metrics
    Prometheus::Client::Formats::Text.marshal(Prometheus::Client.registry)
  end
end
