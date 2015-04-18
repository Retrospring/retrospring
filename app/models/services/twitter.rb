class Services::Twitter < Service
  include Rails.application.routes.url_helpers
  include MarkdownHelper

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
      client.update! prepare_tweet(answer)
    end

    def prepare_tweet(answer)
      # TODO: improve this.
      question_content = twitter_markdown answer.question.content.gsub(/\@(\w+)/, '\1')
      answer_content = twitter_markdown answer.content
      answer_url = show_user_answer_url(
        id: answer.id,
        username: answer.user.screen_name,
        host: APP_CONFIG['hostname'],
        protocol: (APP_CONFIG['https'] ? :https : :http)
      )
      "#{question_content[0..54]}#{'…' if question_content.length > 55}" \
        " — #{answer_content[0..55]}#{'…' if answer_content.length > 56} #{answer_url}"
    end
end
