# frozen_string_literal: true

require "rails_helper"

require "use_case/data_export/relationships"

describe UseCase::DataExport::Relationships, :data_export do
  include ActiveSupport::Testing::TimeHelpers

  context "when user doesn't have any relationships" do
    it "returns an empty set of relationships" do
      expect(json_file("relationships.json")).to eq(
        {
          relationships: []
        }
      )
    end
  end

  context "when user has made some relationships" do
    let(:other_user) { FactoryBot.create(:user) }
    let(:blocked_user) { FactoryBot.create(:user) }
    let(:blocking_user) { FactoryBot.create(:user) }

    let!(:relationships) do
      {
        # user <-> other_user follow each other
        user_to_other: travel_to(Time.utc(2022, 12, 10, 13, 12, 0)) { user.follow(other_user) },
        other_to_user: travel_to(Time.utc(2022, 12, 10, 13, 12, 36)) { other_user.follow(user) },

        # user blocked blocked_user
        block:         travel_to(Time.utc(2022, 12, 10, 13, 37, 42)) { user.block(blocked_user) },

        # user is blocked by blocking_user
        blocked_by:    travel_to(Time.utc(2022, 12, 10, 13, 39, 21)) { blocking_user.block(user) }
      }
    end

    it "returns the relationships as json" do
      expect(json_file("relationships.json")).to eq(
        {
          relationships: [
            {
              id:         relationships[:user_to_other].id,
              source_id:  user.id,
              target_id:  other_user.id,
              created_at: "2022-12-10T13:12:00.000Z",
              updated_at: "2022-12-10T13:12:00.000Z",
              type:       "Relationships::Follow"
            },
            {
              id:         relationships[:block].id,
              source_id:  user.id,
              target_id:  blocked_user.id,
              created_at: "2022-12-10T13:37:42.000Z",
              updated_at: "2022-12-10T13:37:42.000Z",
              type:       "Relationships::Block"
            }
          ]
        }
      )
    end
  end
end
