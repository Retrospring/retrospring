class Theme < ActiveRecord::Base
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
    greater_than_or_equal_to: 0, less_than_or_equal_to: 0xFFFFFF,
    allow_nil: true, only_integer: true

  before_save do
    style = StringIO.new(render_theme_with_context(self).render)
    
    style.class.class_eval {
      attr_accessor :original_filename, :content_type
    }

    style.content_type = 'text/stylesheet'
    style.original_filename = 'theme.css'

    self.css = style
  end
end
