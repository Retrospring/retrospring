# frozen_string_literal: true

require "rails_helper"

require "use_case/data_export/mute_rules"

describe UseCase::DataExport::MuteRules, :data_export do
  include ActiveSupport::Testing::TimeHelpers

  context "when user doesn't have any mute rules" do
    it "returns an empty set of mute rules" do
      expect(json_file("mute_rules.json")).to eq(
        {
          mute_rules: []
        }
      )
    end
  end

  context "when user has some mute rules" do
    let!(:mute_rules) do
      [
        travel_to(Time.utc(2022, 12, 10, 13, 37, 42)) { MuteRule.create(user:, muted_phrase: "test") },
        travel_to(Time.utc(2022, 12, 10, 13, 39, 21)) { MuteRule.create(user:, muted_phrase: "python") }
      ]
    end

    it "returns the mute rules as json" do
      expect(json_file("mute_rules.json")).to eq(
        {
          mute_rules: [
            {
              id:           mute_rules[0].id,
              user_id:      user.id,
              muted_phrase: "test",
              created_at:   "2022-12-10T13:37:42.000Z",
              updated_at:   "2022-12-10T13:37:42.000Z"
            },
            {
              id:           mute_rules[1].id,
              user_id:      user.id,
              muted_phrase: "python",
              created_at:   "2022-12-10T13:39:21.000Z",
              updated_at:   "2022-12-10T13:39:21.000Z"
            }
          ]
        }
      )
    end
  end
end
