# frozen_string_literal: true

require "rails_helper"

describe SocialHelper::TelegramMethods, type: :helper do
  let(:user) { FactoryBot.create(:user) }
  let(:answer) do
    FactoryBot.create(
      :answer,
      user:,
      content:          "this is an answer\nwith multiple lines\nand **FORMATTING**",
      question_content: "this is a question .... or is it?",
    )
  end

  before do
    stub_const("APP_CONFIG", {
                 "hostname"       => "example.com",
                 "https"          => true,
                 "items_per_page" => 5,
               },)
  end

  describe "#telegram_text" do
    subject { telegram_text(answer) }

    it "returns a proper text for sharing" do
      expect(subject).to eq(<<~TEXT.strip)
        this is a question .... or is it?
        ———
        this is an answer
        with multiple lines
        and FORMATTING
      TEXT
    end
  end

  describe "#telegram_share_url" do
    subject { telegram_share_url(answer) }

    it "returns a proper share link" do
      expect(subject).to eq(<<~URL.strip)
        https://t.me/share/url?url=https%3A%2F%2Fexample.com%2F%40#{answer.user.screen_name}%2Fa%2F#{answer.id}&text=this+is+a+question+....+or+is+it%3F%0A%E2%80%94%E2%80%94%E2%80%94%0Athis+is+an+answer%0Awith+multiple+lines%0Aand+FORMATTING
      URL
    end
  end
end
