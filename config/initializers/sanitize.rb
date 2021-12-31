EVIL_TAGS = {
  elements: %w(blockquote a p i strong em del pre code table tr td th br ul ol li hr),
  attributes: {
    'a' => %w(href target rel)
  },
  protocols: {
    'a' => { 'href' => ['http', 'https', :relative] }
  }
}