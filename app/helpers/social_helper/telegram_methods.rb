# frozen_string_literal: true

require "cgi"

module SocialHelper::TelegramMethods
  include MarkdownHelper

  def telegram_text(answer)
    # using twitter_markdown here as it removes all formatting
    "#{twitter_markdown answer.question.content}\n———\n#{twitter_markdown answer.content}"
  end

  def telegram_share_url(answer)
    url = answer_url(
      id:       answer.id,
      username: answer.user.screen_name,
      host:     APP_CONFIG["hostname"],
      protocol: (APP_CONFIG["https"] ? :https : :http)
    )

    %(https://t.me/share/url?url=#{CGI.escape(url)}&text=#{CGI.escape(telegram_text(answer))})
  end
end
