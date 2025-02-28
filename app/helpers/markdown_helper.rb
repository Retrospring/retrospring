# frozen_string_literal: true

module MarkdownHelper
  def markdown(content)
    renderer = FlavoredMarkdown.new(**MARKDOWN_RENDERER_OPTS)
    md = Redcarpet::Markdown.new(renderer, **MARKDOWN_OPTS)
    # As the string has been sanitized we can mark it as HTML safe
    Sanitize.fragment(md.render(content), EVIL_TAGS).strip.html_safe # rubocop:disable Rails/OutputSafety
  end

  def strip_markdown(content)
    renderer = Redcarpet::Render::StripDown.new
    md = Redcarpet::Markdown.new(renderer, **MARKDOWN_OPTS)
    CGI.unescape_html(Sanitize.fragment(CGI.escape_html(md.render(content)), EVIL_TAGS)).strip
  end

  def twitter_markdown(content)
    renderer = TwitteredMarkdown.new
    md = Redcarpet::Markdown.new(renderer, **MARKDOWN_OPTS)
    CGI.unescape_html(Sanitize.fragment(CGI.escape_html(md.render(content)), EVIL_TAGS)).strip
  end

  def question_markdown(content)
    renderer = QuestionMarkdown.new
    md = Redcarpet::Markdown.new(renderer, **MARKDOWN_OPTS)
    # As the string has been sanitized we can mark it as HTML safe
    Sanitize.fragment(md.render(content), EVIL_TAGS).strip.html_safe # rubocop:disable Rails/OutputSafety
  end

  def raw_markdown(content)
    renderer = Redcarpet::Render::HTML.new(**MARKDOWN_RENDERER_OPTS)
    md = Redcarpet::Markdown.new(renderer, **MARKDOWN_OPTS)
    raw md.render content # rubocop:disable Rails/OutputSafety
  end
end
