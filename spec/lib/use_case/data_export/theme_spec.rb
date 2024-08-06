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
            background_color:   "#f0edf4",
            body_text:          "#000000",
            danger_color:       "#dc3545",
            danger_text:        "#ffffff",
            dark_color:         "#343a40",
            dark_text:          "#eeeeee",
            info_color:         "#17a2b8",
            info_text:          "#ffffff",
            input_color:        "#f0edf4",
            input_placeholder:  "#6c757d",
            input_text:         "#000000",
            light_color:        "#f8f9fa",
            light_text:         "#000000",
            muted_text:         "#6c757d",
            primary_color:      "#5e35b1",
            primary_text:       "#ffffff",
            raised_accent:      "#f7f7f7",
            raised_accent_text: "#000000",
            raised_background:  "#ffffff",
            raised_text:        "#000000",
            success_color:      "#28a745",
            success_text:       "#ffffff",
            warning_color:      "#ffc107",
            warning_text:       "#292929",
          },
        },
      )
    end
  end
end
