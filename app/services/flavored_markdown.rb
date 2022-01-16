# frozen_string_literal: true

class FlavoredMarkdown < Redcarpet::Render::HTML
  include Rails.application.routes.url_helpers
  include SharedMarkers

  def preprocess(text)
    wrap_mentions(text)
  end

  def wrap_mentions(text)
    text.gsub(/(^|\s)(@[a-zA-Z0-9_]{1,16})/) do
      "#{$1}[#{$2}](#{show_user_profile_path $2.tr('@', '')})"
    end
  end

  def header(text, _header_level)
    paragraph text
  end

  def paragraph(text)
    "<p>#{text}</p>"
  end

  def raw_html(raw_html)
    Rack::Utils.escape_html raw_html
  end
end
