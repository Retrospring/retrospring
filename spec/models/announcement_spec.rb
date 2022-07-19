# frozen_string_literal: true

require "rails_helper"

RSpec.describe(Announcement, type: :model) do
  include ActiveSupport::Testing::TimeHelpers

  let!(:user) { FactoryBot.create :user }
  let!(:me) do
    Announcement.new(
      content: "Raccoon",
      starts_at: Time.current,
      ends_at: Time.current + 1.day,
      user: user
    )
  end

  describe "#active?" do
    it "returns true when the current time is between starts_at and ends_at" do
      expect(me.active?).to be(true)
    end

    it "returns false when the current time is before starts_at" do
      travel_to(me.starts_at - 1.second)
      expect(me.active?).to be(false)
      travel_back
    end

    it "returns false when the current time is after ends_at" do
      travel_to(me.ends_at + 1.second)
      expect(me.active?).to be(false)
      travel_back
    end
  end

  describe "#link_present?" do
    it "returns true if a link is present" do
      me.link_text = "Very good dogs"
      me.link_href = "https://www.reddit.com/r/rarepuppers/"
      expect(me.link_present?).to be(true)
    end

    it "returns false if a link is not present" do
      me.link_text = nil
      me.link_href = nil
      expect(me.link_present?).to be(false)
    end
  end
end
