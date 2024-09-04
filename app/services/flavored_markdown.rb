# frozen_string_literal: true

class FlavoredMarkdown < Redcarpet::Render::HTML
  include Rails.application.routes.url_helpers
  include SharedMarkers

  def header(text, _header_level)
    "<p>#{text}</p>"
  end

  def raw_html(raw_html)
    Rack::Utils.escape_html raw_html
  end
end
