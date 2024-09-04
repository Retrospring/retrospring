# frozen_string_literal: true

require "rails_helper"

describe ThemeHelper, type: :helper do
  describe "#render_theme" do
    context "when target page doesn't have a theme" do
      it "returns no theme" do
        expect(helper.render_theme).to be_nil
      end
    end
  end

  describe "#get_hex_color_from_theme_value" do
    it "returns the proper hex value from the decimal value for white" do
      expect(helper.get_hex_color_from_theme_value(16777215)).to eq("ffffff")
    end

    it "returns the proper hex value from the decimal value for purple" do
      expect(helper.get_hex_color_from_theme_value(6174129)).to eq("5e35b1")
    end

    it "returns the proper hex value from the decimal value for blue" do
      expect(helper.get_hex_color_from_theme_value(255)).to eq("0000ff")
    end
  end

  describe "#get_decimal_triplet_from_hex" do
    it "returns the proper decimal triplet from a hex value" do
      expect(helper.get_decimal_triplet_from_hex("5e35b1")).to eq("94, 53, 177")
    end
  end
end
