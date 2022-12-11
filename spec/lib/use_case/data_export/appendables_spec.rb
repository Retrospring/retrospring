# frozen_string_literal: true

require "rails_helper"

require "use_case/data_export/appendables"

describe UseCase::DataExport::Appendables, :data_export do
  include ActiveSupport::Testing::TimeHelpers

  context "when user doesn't have any appendable" do
    it "returns an empty set of appendables" do
      expect(json_file("appendables.json")).to eq(
        {
          appendables: []
        }
      )
    end
  end

  context "when user has smiled some things" do
    let(:answer) { FactoryBot.create(:answer, user:) }
    let(:comment) { FactoryBot.create(:comment, user:, answer:) }

    let!(:appendables) do
      [
        travel_to(Time.utc(2022, 12, 10, 13, 37, 42)) { FactoryBot.create(:comment_smile, user:, parent: comment) },
        travel_to(Time.utc(2022, 12, 10, 13, 39, 21)) { FactoryBot.create(:smile, user:, parent: answer) }
      ]
    end

    it "returns the appendables as json" do
      expect(json_file("appendables.json")).to eq(
        {
          appendables: [
            {
              id:          appendables[0].id,
              type:        "Appendable::Reaction",
              user_id:     user.id,
              parent_id:   appendables[0].parent_id,
              parent_type: "Comment",
              content:     "🙂",
              created_at:  "2022-12-10T13:37:42.000Z",
              updated_at:  "2022-12-10T13:37:42.000Z"
            },
            {
              id:          appendables[1].id,
              type:        "Appendable::Reaction",
              user_id:     user.id,
              parent_id:   appendables[1].parent_id,
              parent_type: "Answer",
              content:     "🙂",
              created_at:  "2022-12-10T13:39:21.000Z",
              updated_at:  "2022-12-10T13:39:21.000Z"
            }
          ]
        }
      )
    end
  end
end
