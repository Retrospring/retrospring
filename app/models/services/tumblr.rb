class Services::Tumblr < Service
  include SocialHelper::TumblrMethods

  def provider
    "tumblr"
  end

  def post(answer)
    Rails.logger.debug "posting to Tumblr {'answer' => #{answer.id}, 'user' => #{self.user_id}}"
    create_post answer
  end

  private

    def client
      @client ||= Tumblr::Client.new(
          consumer_key: APP_CONFIG['sharing']['tumblr']['consumer_key'],
          consumer_secret: APP_CONFIG['sharing']['tumblr']['consumer_secret'],
          oauth_token: self.access_token,
          oauth_token_secret: self.access_secret
      )
    end

    def create_post(answer)
      client.text(
          self.uid,
          title: tumblr_title(answer),
          body: tumblr_body(answer),
          format: 'markdown',
          tweet: 'off'
      )
    end
end