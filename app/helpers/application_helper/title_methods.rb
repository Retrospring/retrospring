# frozen_string_literal: true

module ApplicationHelper::TitleMethods
  include MarkdownHelper

  def generate_title(name, junction = nil, content = nil, possessive = false)
    if possessive
      name = if name[-1].downcase == "s"
               "#{name}'"
             else
               "#{name}'s"
             end
    end

    list = [name, junction].compact

    unless content.nil?
      content = strip_markdown(content)
      content = "#{content[0..42]}…" if content.length > 45
      list.push content
    end
    list.push "|", APP_CONFIG["site_name"]

    list.join " "
  end
end
