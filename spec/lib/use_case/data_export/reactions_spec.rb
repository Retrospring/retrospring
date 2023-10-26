# frozen_string_literal: true

require "rails_helper"

describe UseCase::DataExport::Reactions, :data_export do
  include ActiveSupport::Testing::TimeHelpers

  context "when user doesn't have any reactions" do
    it "returns an empty set of reactions" do
      expect(json_file("reactions.json")).to eq(
        {
          reactions: [],
        }
      )
    end
  end

  context "when user has smiled some things" do
    let(:answer) { FactoryBot.create(:answer, user:) }
    let(:comment) { FactoryBot.create(:comment, user:, answer:) }

    let!(:reactions) do
      [
        travel_to(Time.utc(2022, 12, 10, 13, 37, 42)) { FactoryBot.create(:comment_smile, user:, parent: comment) },
        travel_to(Time.utc(2022, 12, 10, 13, 39, 21)) { FactoryBot.create(:smile, user:, parent: answer) }
      ]
    end

    it "returns the reactions as json" do
      expect(json_file("reactions.json")).to eq(
        {
          reactions: [
            {
              id:          reactions[0].id,
              user_id:     user.id,
              parent_id:   reactions[0].parent_id,
              parent_type: "Comment",
              content:     "🙂",
              created_at:  "2022-12-10T13:37:42.000Z",
              updated_at:  "2022-12-10T13:37:42.000Z"
            },
            {
              id:          reactions[1].id,
              user_id:     user.id,
              parent_id:   reactions[1].parent_id,
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
