# frozen_string_literal: true

require "rails_helper"

describe MetricsController, type: :controller do
  describe "#show" do
    subject { get :show }

    it "returns the metrics" do
      # ensure we have at least a metric set
      Retrospring::Metrics::VERSION_INFO.set 1

      expect(subject.body).to include "retrospring_version_info"
    end
  end
end
