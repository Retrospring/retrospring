# frozen_string_literal: true

require "rails_helper"

describe UseCase::DataExport::Theme, :data_export do
  include ActiveSupport::Testing::TimeHelpers

  context "when user doesn't have a theme" do
    it "returns nothing" do
      expect(subject).to eq({})
    end
  end

  context "when user has a theme" do
    let!(:theme) do
      travel_to(Time.utc(2022, 12, 10, 13, 37, 42)) do
        FactoryBot.create(:theme, user:)
      end
    end

    it "returns the theme as json" do
      expect(json_file("theme.json")).to eq(
        {
          theme: {
            id:                theme.id,
            user_id:           user.id,
            primary_color:     9342168,
            primary_text:      16777215,
            danger_color:      14257035,
            danger_text:       16777215,
            success_color:     12573067,
            success_text:      16777215,
            warning_color:     14261899,
            warning_text:      16777215,
            info_color:        9165273,
            info_text:         16777215,
            dark_color:        6710886,
            dark_text:         15658734,
            raised_background: 16777215,
            background_color:  13026795,
            body_text:         3355443,
            muted_text:        3355443,
            created_at:        "2022-12-10T13:37:42.000Z",
            updated_at:        "2022-12-10T13:37:42.000Z",
            input_color:       15789556,
            input_text:        6710886,
            raised_accent:     16250871,
            light_color:       16316922,
            light_text:        0,
            input_placeholder: 7107965
          }
        }
      )
    end
  end
end
