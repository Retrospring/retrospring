# frozen_string_literal: true

module SocialHelper
  include SocialHelper::BlueskyMethods
  include SocialHelper::TwitterMethods
  include SocialHelper::TumblrMethods
  include SocialHelper::TelegramMethods

  def answer_share_url(answer)
    answer_url(
      id:       answer.id,
      username: answer.user.screen_name,
      host:     APP_CONFIG["hostname"],
      protocol: (APP_CONFIG["https"] ? :https : :http),
    )
  end
end
