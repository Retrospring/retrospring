# frozen_string_literal: true

require "rails_helper"

describe MetricsController, type: :controller do
  describe "#show" do
    subject { get :show }

    it "returns the metrics" do
      expect(subject.body).to include "retrospring_version_info"
    end
  end
end
