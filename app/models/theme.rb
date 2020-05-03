class Theme < ApplicationRecord
  include ThemeHelper

  belongs_to :user

  validates_numericality_of :primary_color, :primary_text,
    :danger_color, :danger_text,
    :success_color, :success_text,
    :warning_color, :warning_text,
    :info_color, :info_text,
    :default_color, :default_text,
    :panel_color, :panel_text,
    :link_color, :background_color,
    :background_text, :background_muted,
    :input_color, :input_text,
    :outline_color,
    greater_than_or_equal_to: 0, less_than_or_equal_to: 0xFFFFFF,
    allow_nil: true, only_integer: true

  def theme_color
    ('#' + ('0000000' + primary_color.to_s(16))[-6, 6])
  end
end
