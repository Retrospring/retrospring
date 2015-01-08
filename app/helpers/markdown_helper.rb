module MarkdownHelper

  def markdown(content)
    md = Redcarpet::Markdown.new(FlavoredMarkdown,
                                 filter_html: true,
                                 escape_html: true,
                                 no_images: true,
                                 no_styles: true,
                                 safe_links_only: true,
                                 xhtml: false,
                                 hard_wrap: true,
                                 no_intra_emphasis: true,
                                 tables: true,
                                 fenced_code_blocks: true,
                                 autolink: true,
                                 disable_indented_code_blocks: true,
                                 strikethrough: true,
                                 superscript: false)
    Sanitize.fragment(md.render(content), EVIL_TAGS).html_safe
  end
end