module MarkdownHelper

  def markdown(content)
    md = Redcarpet::Markdown.new(FlavoredMarkdown, MARKDOWN_OPTS)
    Sanitize.fragment(md.render(content), EVIL_TAGS).html_safe
  end

  def strip_markdown(content)
    md = Redcarpet::Markdown.new(Redcarpet::Render::StripDown, MARKDOWN_OPTS)
    CGI.unescape_html(Sanitize.fragment(md.render(content), EVIL_TAGS)).strip
  end

  def twitter_markdown(content)
    md = Redcarpet::Markdown.new(TwitteredMarkdown, MARKDOWN_OPTS)
    CGI.unescape_html(Sanitize.fragment(md.render(content), EVIL_TAGS)).strip
  end
end