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

  def question_markdown(content)
    md = Redcarpet::Markdown.new(QuestionMarkdown.new, MARKDOWN_OPTS)
    Sanitize.fragment(md.render(content), EVIL_TAGS).html_safe
  end

  def raw_markdown(content)
    md = Redcarpet::Markdown.new(Redcarpet::Render::HTML, RAW_MARKDOWN_OPTS)
    raw md.render content
  end

  def get_markdown(path, relative_to = Rails.root)
    begin
      File.read relative_to.join(path)
    rescue Errno::ENOENT
      "# Error reading #{relative_to.join(path)}"
    end
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
