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
      question_content = twitter_markdown answer.question.content.gsub(/\@(\w+)/, '\1')
      original_question_length = question_content.length
      answer_content = twitter_markdown answer.content
      original_answer_length = answer_content.length
      answer_url = show_user_answer_url(
        id: answer.id,
        username: answer.user.screen_name,
        host: APP_CONFIG['hostname'],
        protocol: (APP_CONFIG['https'] ? :https : :http)
      )

      parsed_tweet = { :valid => false }
      tweet_text = ""

      until parsed_tweet[:valid]
        tweet_text = "#{question_content[0..122]}#{'…' if original_question_length > [123, question_content.length].min}" \
          " — #{answer_content[0..123]}#{'…' if original_answer_length > [124, answer_content.length].min} #{answer_url}"

        parsed_tweet = Twitter::TwitterText::Validation::parse_tweet(tweet_text)

        question_content = question_content[0..-2]
        answer_content = answer_content[0..-2]
      end

      tweet_text
    end
end
