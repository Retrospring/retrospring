# frozen_string_literal: true

require "uri"

class QuestionMarkdown < Redcarpet::Render::StripDown
  include Rails.application.routes.url_helpers
  include SharedMarkers

  def paragraph(text)
    "<p>#{text}</p>"
  end

  def link(link, _title, _content)
    process_link(link)
  end
end
