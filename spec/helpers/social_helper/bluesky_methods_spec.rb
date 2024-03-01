# frozen_string_literal: true

require "rails_helper"

describe SocialHelper::BlueskyMethods, type: :helper do
  include SocialHelper::TwitterMethods

  let(:user) { FactoryBot.create(:user) }
  let(:question_content) { "q" * 255 }
  let(:answer_content) { "a" * 255 }
  let(:answer) do
    FactoryBot.create(:answer, user:,
                               content:          answer_content,
                               question_content:,)
  end

  before do
    stub_const("APP_CONFIG", {
                 "hostname"       => "example.com",
                 "https"          => true,
                 "items_per_page" => 5,
               },)
  end

  describe "#bluesky_share_url" do
    subject { bluesky_share_url(answer) }

    it "should return a proper share link" do
      expect(subject).to eq("https://bsky.app/intent/compose?text=#{CGI.escape(prepare_tweet(answer))}")
    end
  end
end
