class Services::Twitter < Service
  include Rails.application.routes.url_helpers
  include SocialHelper::TwitterMethods

  def provider
    "twitter"
  end

  def post(answer)
    Rails.logger.debug "posting to Twitter {'answer' => #{answer.id}, 'user' => #{self.user_id}}"
    post_tweet answer
  end

  private

    def client
      @client ||= Twitter::REST::Client.new(
        consumer_key: APP_CONFIG['sharing']['twitter']['consumer_key'],
        consumer_secret: APP_CONFIG['sharing']['twitter']['consumer_secret'],
        access_token: self.access_token,
        access_token_secret: self.access_secret
      )
    end

    def post_tweet(answer)
      client.update! prepare_tweet(answer, self.post_tag)
    end
end
