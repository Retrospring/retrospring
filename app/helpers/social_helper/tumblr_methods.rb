require 'cgi'

module SocialHelper::TumblrMethods
  def tumblr_title(answer)
    asker = if answer.question.author_is_anonymous?
              answer.user.profile.anon_display_name.presence || APP_CONFIG["anonymous_name"]
            else
              answer.question.user.profile.safe_name
            end

    "#{asker} asked: #{answer.question.content}"
  end

  def tumblr_body(answer)
    answer_url = show_user_answer_url(
        id: answer.id,
        username: answer.user.screen_name,
        host: APP_CONFIG['hostname'],
        protocol: (APP_CONFIG['https'] ? :https : :http)
    )

    "#{answer.content}\n\n[Smile or comment on the answer here](#{answer_url})"
  end

  def tumblr_share_url(answer)
    answer_url = show_user_answer_url(
      id: answer.id,
      username: answer.user.screen_name,
      host: APP_CONFIG['hostname'],
      protocol: (APP_CONFIG['https'] ? :https : :http)
    )

    "https://www.tumblr.com/widgets/share/tool?shareSource=legacy&posttype=text&title=#{CGI.escape(tumblr_title(answer))}&url=#{CGI.escape(answer_url)}&caption=&content=#{CGI.escape(tumblr_body(answer))}"
  end
end