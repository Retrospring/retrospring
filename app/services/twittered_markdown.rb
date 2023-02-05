# frozen_string_literal: true

class TwitteredMarkdown < Redcarpet::Render::StripDown
  def preprocess(text)
    wrap_mentions(text)
  end

  def wrap_mentions(text)
    text.gsub(/(^|\s)@([a-zA-Z0-9_]{1,16})/) do
      "#{$1}#{$2}"
    end
  end
end
