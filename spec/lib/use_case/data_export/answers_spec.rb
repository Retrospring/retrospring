# frozen_string_literal: true

require "rails_helper"

describe UseCase::DataExport::Answers, :data_export do
  include ActiveSupport::Testing::TimeHelpers

  context "when user doesn't have any answers" do
    it "returns an empty set of answers" do
      expect(json_file("answers.json")).to eq(
        {
          answers: []
        }
      )
    end
  end

  context "when user has made some answer" do
    let!(:answer) do
      travel_to(Time.utc(2022, 12, 10, 13, 37, 42)) { FactoryBot.create(:answer, user:, content: "Yay, data export!") }
    end

    it "returns the answers as json" do
      expect(json_file("answers.json")).to eq(
        {
          answers: [
            {
              id:            answer.id,
              content:       "Yay, data export!",
              question_id:   answer.question.id,
              comment_count: 0,
              user_id:       user.id,
              created_at:    "2022-12-10T13:37:42.000Z",
              updated_at:    "2022-12-10T13:37:42.000Z",
              smile_count:   0
            }
          ]
        }
      )
    end
  end
end
