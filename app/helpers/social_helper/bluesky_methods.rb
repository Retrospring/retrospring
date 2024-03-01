# frozen_string_literal: true

require "cgi"

module SocialHelper::BlueskyMethods
  def bluesky_share_url(answer)
    "https://bsky.app/intent/compose?text=#{CGI.escape(prepare_tweet(answer))}"
  end
end
