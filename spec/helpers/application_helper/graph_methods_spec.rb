# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper::GraphMethods, type: :helper do
  describe "#user_opengraph" do
    context "sample user" do
      let(:user) do
        FactoryBot.create(:user,
                          profile:     { display_name: "Cunes",
                                         description:  "A bunch of raccoons in a trenchcoat.", },
                          screen_name: "raccoons",)
      end

      subject { user_opengraph(user) }

      it "should generate a matching OpenGraph structure for a user" do
        allow(APP_CONFIG).to receive(:[]).with("site_name").and_return("pineapplespring")
        expect(subject).to eq(<<~META.chomp)
          <meta property="og:title" content="Cunes">
          <meta property="og:type" content="profile">
          <meta property="og:image" content="http://test.host/images/large/no_avatar.png">
          <meta property="og:url" content="http://test.host/@raccoons">
          <meta property="og:description" content="A bunch of raccoons in a trenchcoat.">
          <meta property="og:site_name" content="pineapplespring">
          <meta property="profile:username" content="raccoons">
        META
      end
    end
  end

  describe "#user_twitter_card" do
    context "sample user" do
      let(:user) do
        FactoryBot.create(:user,
                          profile:     {
                            display_name: "",
                            description:  "A bunch of raccoons in a trenchcoat.",
                          },
                          screen_name: "raccoons",)
      end

      subject { user_twitter_card(user) }
      it "should generate a matching OpenGraph structure for a user" do
        expect(subject).to eq(<<~META.chomp)
          <meta name="twitter:card" content="summary">
          <meta name="twitter:site" content="@retrospring">
          <meta name="twitter:title" content="Ask me anything!">
          <meta name="twitter:description" content="Ask raccoons anything on Retrospring">
          <meta name="twitter:image" content="http://test.host/images/large/no_avatar.png">
        META
      end
    end
  end

  describe "#answer_opengraph" do
    context "sample user and answer" do
      let!(:user) do
        FactoryBot.create(:user,
                          profile:     {
                            display_name: "",
                            description:  "A bunch of raccoons in a trenchcoat.",
                          },
                          screen_name: "raccoons",)
      end
      let(:answer) do
        FactoryBot.create(:answer,
                          user_id: user.id,)
      end

      subject { answer_opengraph(answer) }

      it "should generate a matching OpenGraph structure for a user" do
        allow(APP_CONFIG).to receive(:[]).with("site_name").and_return("pineapplespring")
        expect(subject).to eq(<<~META.chomp)
          <meta property="og:title" content="raccoons answered: #{answer.question.content}">
          <meta property="og:type" content="article">
          <meta property="og:image" content="http://test.host/images/large/no_avatar.png">
          <meta property="og:url" content="http://test.host/@raccoons/a/#{answer.id}">
          <meta property="og:description" content="#{answer.content}">
          <meta property="og:site_name" content="pineapplespring">
        META
      end
    end
  end
end
