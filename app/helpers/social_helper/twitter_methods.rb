require 'cgi'

module SocialHelper::TwitterMethods
  include Rails.application.routes.url_helpers
  include MarkdownHelper

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

  def twitter_share_url(answer)
    "https://twitter.com/intent/tweet?text=#{CGI.escape(prepare_tweet(answer))}"
  end
end