require 'redcarpet/render_strip'

MARKDOWN_OPTS = {
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
    superscript: false
}

RAW_MARKDOWN_OPTS = {
  tables: true,
  fenced_code_blocks: true,
  autolink: true,
  disable_indented_code_blocks: true,
  strikethrough: true,
  superscript: false
}

ALLOWED_HOSTS_IN_MARKDOWN = [
  APP_CONFIG['hostname'],
  *APP_CONFIG['allowed_hosts_in_markdown']
]