# frozen_string_literal: true

require "rails_helper"

require "use_case/data_export/comments"

describe UseCase::DataExport::Comments, :data_export do
  include ActiveSupport::Testing::TimeHelpers

  context "when user doesn't have any comments" do
    it "returns an empty set of comments" do
      expect(json_file("comments.json")).to eq(
        {
          comments: []
        }
      )
    end
  end

  context "when user has made some comment" do
    let(:answer) { FactoryBot.create(:answer, user:) }

    let!(:comment) do
      travel_to(Time.utc(2022, 12, 10, 13, 37, 42)) { FactoryBot.create(:comment, user:, answer:, content: "Yay, data export!") }
    end

    it "returns the comments as json" do
      expect(json_file("comments.json")).to eq(
        {
          comments: [
            {
              id:          comment.id,
              content:     "Yay, data export!",
              answer_id:   answer.id,
              user_id:     user.id,
              created_at:  "2022-12-10T13:37:42.000Z",
              updated_at:  "2022-12-10T13:37:42.000Z",
              smile_count: 0
            }
          ]
        }
      )
    end
  end
end
