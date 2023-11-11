# frozen_string_literal: true

require "rails_helper"

describe SocialHelper, type: :helper do
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

  describe "#answer_share_url" do
    subject { answer_share_url(answer) }

    it "returns a proper share link" do
      expect(subject).to eq(<<~URL.strip)
        https://example.com/@#{answer.user.screen_name}/a/#{answer.id}
      URL
    end
  end

  describe "#answer_copy_content" do
    subject { answer_copy_content(answer) }

    it "returns a formatted content to copy" do
      expected_content = "#{answer.question.content} - #{answer.content} [https://example.com/@#{answer.user.screen_name}/a/#{answer.id}]"

      expect(subject).to eq(expected_content)
    end
  end
end
