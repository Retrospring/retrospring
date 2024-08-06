# frozen_string_literal: true

require "rails_helper"

describe UseCase::DataExport::Theme,
         :data_export do
  include ActiveSupport::Testing::TimeHelpers

  context "when user doesn't have a theme" do
    it "returns nothing" do
      expect(subject).to eq({})
    end
  end

  context "when user has a theme" do
    let!(:theme) do
      travel_to(Time.utc(2022,
                         12,
                         10,
                         13,
                         37,
                         42,)) do
        FactoryBot.create(:theme,
                          user:,)
      end
    end

    it "returns the theme as json" do
      expect(json_file("theme.json")).to eq(
        {
          theme: {
            background_color:   "#c6c5eb",
            body_text:          "#333333",
            danger_color:       "#d98b8b",
            danger_text:        "#ffffff",
            dark_color:         "#666666",
            dark_text:          "#eeeeee",
            info_color:         "#8bd9d9",
            info_text:          "#ffffff",
            input_color:        "#f0edf4",
            input_placeholder:  "#6c757d",
            input_text:         "#666666",
            light_color:        "#f8f9fa",
            light_text:         "#000000",
            muted_text:         "#333333",
            primary_color:      "#8e8cd8",
            primary_text:       "#ffffff",
            raised_accent:      "#f7f7f7",
            raised_accent_text: "#333333",
            raised_background:  "#ffffff",
            raised_text:        "#333333",
            success_color:      "#bfd98b",
            success_text:       "#ffffff",
            warning_color:      "#d99e8b",
            warning_text:       "#ffffff",
          },
        },
      )
    end
  end
end
