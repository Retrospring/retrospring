# frozen_string_literal: true

return unless ENV["SEARCH_ENABLED"] == "true"

MeiliSearch::Rails.configuration = {
  meilisearch_url: ENV.fetch("MEILISEARCH_HOST", "http://localhost:7700"),
  meilisearch_api_key: ENV.fetch("MEILISEARCH_API_KEY", "justfordev42069e621")
}
