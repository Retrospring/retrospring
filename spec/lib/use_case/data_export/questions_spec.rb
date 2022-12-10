# frozen_string_literal: true

require "rails_helper"

require "use_case/data_export/questions"

describe UseCase::DataExport::Questions, :data_export do
  include ActiveSupport::Testing::TimeHelpers

  context "when user doesn't have any questions" do
    it "returns an empty set of questions" do
      expect(json_file("questions.json")).to eq(
        {
          questions: []
        }
      )
    end
  end

  context "when user has made some questions" do
    let!(:questions) do
      [
        travel_to(Time.utc(2022, 12, 10, 13, 12, 0)) { FactoryBot.create(:question, user:, content: "Yay, data export 1", author_is_anonymous: false, direct: false, answer_count: 12) },
        travel_to(Time.utc(2022, 12, 10, 13, 37, 42)) { FactoryBot.create(:question, user:, content: "Yay, data export 2", author_is_anonymous: false, direct: true, answer_count: 1) },
        travel_to(Time.utc(2022, 12, 10, 13, 39, 21)) { FactoryBot.create(:question, user:, content: "Yay, data export 3", author_is_anonymous: true, direct: true) }
      ]
    end

    it "returns the questions as json" do
      expect(json_file("questions.json")).to eq(
        {
          questions: [
            {
              id:                  questions[0].id,
              content:             "Yay, data export 1",
              author_is_anonymous: false,
              user_id:             user.id,
              created_at:          "2022-12-10T13:12:00.000Z",
              updated_at:          "2022-12-10T13:12:00.000Z",
              answer_count:        12,
              direct:              false
            },
            {
              id:                  questions[1].id,
              content:             "Yay, data export 2",
              author_is_anonymous: false,
              user_id:             user.id,
              created_at:          "2022-12-10T13:37:42.000Z",
              updated_at:          "2022-12-10T13:37:42.000Z",
              answer_count:        1,
              direct:              true
            },
            {
              id:                  questions[2].id,
              content:             "Yay, data export 3",
              author_is_anonymous: true,
              user_id:             user.id,
              created_at:          "2022-12-10T13:39:21.000Z",
              updated_at:          "2022-12-10T13:39:21.000Z",
              answer_count:        0,
              direct:              true
            }
          ]
        }
      )
    end
  end
end
