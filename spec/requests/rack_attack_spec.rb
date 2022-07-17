# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Rack::Attack", type: :request do
  include ActiveSupport::Testing::TimeHelpers
  include Warden::Test::Helpers

  before(:each) do
    Rack::Attack.enabled = true
    Rack::Attack.reset! 
  end

  describe "throttle_unauthenticated_asking" do
    it "should throttle unauthenticated users" do
      3.times do
        post "/ajax/ask"
        expect(response.status).to eq(200)
      end

      post "/ajax/ask"
      expect(response.status).to eq(429)
    end

    it "should unthrottle after the given period" do
      3.times do
        post "/ajax/ask"
        expect(response.status).to eq(200)
      end

      post "/ajax/ask"
      expect(response.status).to eq(429)

      travel_to(5.minutes.from_now) do
        post "/ajax/ask"
        expect(response.status).to eq(200)
      end
    end
  end

  describe "throttle_authenticated_asking" do
    let (:user) { FactoryBot.create(:user) }

    it "should throttle authenticated users" do
      login_as user, scope: :user

      30.times do
        post "/ajax/ask"
        expect(response.status).to eq(200)
      end

      post "/ajax/ask"
      expect(response.status).to eq(429)
    end

    it "should unthrottle after the given period" do
      login_as user, scope: :user

      30.times do
        post "/ajax/ask"
        expect(response.status).to eq(200)
      end

      post "/ajax/ask"
      expect(response.status).to eq(429)

      travel_to(20.minutes.from_now) do
        post "/ajax/ask"
        expect(response.status).to eq(200)
      end
    end
  end
end
