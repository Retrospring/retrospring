# frozen_string_literal: true

require "rails_helper"

describe ManifestsController, type: :controller do
  describe "#show" do
    subject { get :show }

    before do
      stub_const("APP_CONFIG", {
                   "site_name"      => "Specspring",
                   "hostname"       => "test.host",
                   "https"          => false,
                   "items_per_page" => 5
                 })
    end

    it "returns a web app manifest" do
      subject
      expect(response).to have_http_status(200)
      body = JSON.parse(response.body)

      expect(body["name"]).to eq("Specspring")
      expect(body["start_url"]).to eq("http://test.host/")
      expect(body["scope"]).to eq("http://test.host/")
      expect(body["theme_color"]).to eq("#5e35b1")
    end
  end
end
