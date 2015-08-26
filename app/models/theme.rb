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
    :input_color, :input_text,
    :outline_color,
    greater_than_or_equal_to: 0, less_than_or_equal_to: 0xFFFFFF,
    allow_nil: true, only_integer: true

  has_attached_file :css, use_timestamp: false, s3_headers: {
    'Content-Type' => 'text/css'
  }, fog_file: {
    content_type: 'text/css'
  }
  validates_attachment_content_type :css, content_type: /^text\//

  before_save do
    self.css = nil

    style = StringIO.new(render_theme_with_context(self))

    style.class.class_eval { attr_accessor :original_filename, :content_type }

    style.content_type = 'text/css'
    style.original_filename = 'theme.css'

    self.css = style
  end

  def theme_color
    ('#' + ('0000000' + primary_color.to_s(16))[-6, 6])
  end
end
