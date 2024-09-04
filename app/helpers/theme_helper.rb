# frozen_string_literal: true

module ThemeHelper
  def render_theme = nil

  def get_color_for_key(key, color)
    hex = get_hex_color_from_theme_value(color)

    if key.include?("text") || key.include?("placeholder") || key.include?("rgb")
      get_decimal_triplet_from_hex(hex)
    else
      "##{hex}"
    end
  end

  def theme_color = "#5e35b1"

  def mobile_theme_color = "#f0edf4"

  def get_hex_color_from_theme_value(value)
    "0000000#{value.to_s(16)}"[-6, 6]
  end

  def get_decimal_triplet_from_hex(value)
    hexes = value.split(/(.{2})/).reject(&:empty?)
    hexes.map(&:hex).join(", ")
  end

  def rgb_values_from_hex(value)
    [
      (value & 0xFF0000) >> 16, # R
      (value & 0x00FF00) >> 8, # G
      value & 0x0000FF # B
    ]
  end

  def rgb_to_hex(rgb_values)
    rgb_values.map.with_index { |v, i| v << ((2 - i) * 8) }.reduce(&:+).to_s(16)
  end

  def lighten(value, amount = 0.25)
    rgb_to_hex(rgb_values_from_hex(value).map { |v| [(v + (255 * amount)).round, 255].min })
  end
end
