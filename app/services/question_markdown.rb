require 'uri'

class QuestionMarkdown < Redcarpet::Render::Base
  include Rails.application.routes.url_helpers
  include SharedMarkers

  def paragraph(text)
    "<p>#{text}</p>"
  end
end