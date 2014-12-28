EVIL_TAGS = {
  elements: %w(quote a p i strong em del pre code table tr td th br ul ol li hr),
  attributes: {
    'a' => %w(href)
  },
  protocols: {
    'a' => { 'href' => ['http', 'https', :relative] }
  }
}