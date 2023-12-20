class Theme < ApplicationRecord
  include ThemeHelper

  belongs_to :user

  scope :built_in, -> { where(user_id: nil) }

  validates_numericality_of :primary_color, :primary_text,
    :danger_color, :danger_text,
    :success_color, :success_text,
    :warning_color, :warning_text,
    :info_color, :info_text,
    :dark_color, :dark_text,
    :light_color, :light_text,
    :raised_background, :raised_accent,
    :background_color, :body_text,
    :muted_text, :input_color,
    :input_text,
    greater_than_or_equal_to: 0, less_than_or_equal_to: 0xFFFFFF,
    allow_nil: true, only_integer: true

  def to_css
    body = ""
    attributes.each do |k, v|
      next unless ATTRIBUTE_MAP.key?(k)

      Array(ATTRIBUTE_MAP[k]).each do |var|
        body += "\t--#{var}: #{get_color_for_key(var, v)};\n"
      end
    end
    body + "\t--turbolinks-progress-color: ##{lighten(primary_color)}\n"
  end

  def theme_color
    ('#' + ('0000000' + primary_color.to_s(16))[-6, 6])
  end

  def mobile_theme_color
    ('#' + ('0000000' + background_color.to_s(16))[-6, 6])
  end
end
