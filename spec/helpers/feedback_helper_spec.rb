# frozen_string_literal: true

require "rails_helper"

describe FeedbackHelper, type: :helper do
  before do
    stub_const("APP_CONFIG", {
                 "hostname"       => "example.com",
                 "https"          => true,
                 "items_per_page" => 5,
                 "canny"          => {
                   sso:           "sso",
                   feature_board: "feature",
                   bug_board:     "bug",
                 },
               },)
  end

  describe "#canny_token" do
    context "user signed in" do
      let(:user) { FactoryBot.create(:user, id: 10, screen_name: "canned_laughter", email: "can@do.com") }

      before(:each) do
        sign_in(user)
      end

      it "should return a proper token" do
        expect(helper.canny_token).to eq("eyJhbGciOiJIUzI1NiJ9.eyJhdmF0YXJVUkwiOiIvaW1hZ2VzL2xhcmdlL25vX2F2YXRhci5wbmciLCJuYW1lIjoiY2FubmVkX2xhdWdodGVyIiwiaWQiOjEwLCJlbWFpbCI6ImNhbkBkby5jb20ifQ.aRZn8kAezMJucYQV4RXiMPvhSRVR3wKp1ZQtcsIWaaE")
      end
    end

    context "user not signed in" do
      it "should return nothing" do
        expect(helper.canny_token).to eq(nil)
      end
    end
  end
end
