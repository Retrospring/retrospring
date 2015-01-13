class Services::Tumblr < Service
  include Rails.application.routes.url_helpers
  include MarkdownHelper

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
      answer_url = show_user_answer_url(
          id: answer.id,
          username: answer.user.screen_name,
          host: APP_CONFIG['hostname'],
          protocol: (APP_CONFIG['https'] ? :https : :http)
      )
      asker = if answer.question.author_is_anonymous?
                APP_CONFIG['anonymous_name']
              else
                answer.question.user.display_name.blank? ? answer.question.user.screen_name : answer.question.user.display_name
              end
      client.text(
          self.uid,
          title: "#{asker} asked: #{answer.question.content}",
          body: "#{answer.content}\n\n[Smile or comment on the answer here](#{answer_url})",
          format: 'markdown',
          tweet: 'off'
      )
    end
end