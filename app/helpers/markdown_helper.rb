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
    raw md.render content
  end

  def get_markdown(path, relative_to = Rails.root)
    File.read relative_to.join(path)
  rescue Errno::ENOENT
    "# Error reading #{relative_to.join(path)}"
  end

  def markdown_io(path, relative_to = Rails.root)
    markdown get_markdown path, relative_to
  end

  def strip_markdown_io(path, relative_to = Rails.root)
    strip_markdown get_markdown path, relative_to
  end

  def twitter_markdown_io(path, relative_to = Rails.root)
    twitter_markdown get_markdown path, relative_to
  end

  def raw_markdown_io(path, relative_to = Rails.root)
    raw_markdown get_markdown path, relative_to
  end
end
