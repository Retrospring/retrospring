# frozen_string_literal: true

module ApplicationHelper::GraphMethods
  # Creates <meta> tags for OpenGraph properties from a hash
  # @param values [Hash]
  def opengraph_meta_tags(values)
    safe_join(values.map { |name, content| tag.meta(property: name, content: content) }, "\n")
  end

  # Creates <meta> tags from a hash
  # @param values [Hash]
  def meta_tags(values)
    safe_join(values.map { |name, content| tag.meta(name: name, content: content) }, "\n")
  end

  # @param user [User]
  def user_opengraph(user)
    opengraph_meta_tags({
                          "og:title":         user.profile.safe_name,
                          "og:type":          "profile",
                          "og:image":         full_profile_picture_url(user),
                          "og:url":           user_url(user),
                          "og:description":   user.profile.description,
                          "og:site_name":     APP_CONFIG["site_name"],
                          "profile:username": user.screen_name
                        })
  end

  # @param user [User]
  def user_twitter_card(user)
    meta_tags({
                "twitter:card":        "summary",
                "twitter:site":        "@retrospring",
                "twitter:title":       user.profile.motivation_header.presence || "Ask me anything!",
                "twitter:description": "Ask #{user.profile.safe_name} anything on Retrospring",
                "twitter:image":       full_profile_picture_url(user)
              })
  end

  # @param answer [Answer]
  def answer_opengraph(answer)
    opengraph_meta_tags({
                          "og:title":       "#{answer.user.profile.safe_name} answered: #{answer.question.content}",
                          "og:type":        "article",
                          "og:image":       full_profile_picture_url(answer.user),
                          "og:url":         answer_url(answer.user.screen_name, answer.id),
                          "og:description": answer.content,
                          "og:site_name":   APP_CONFIG["site_name"]
                        })
  end

  def full_profile_picture_url(user)
    # @type [String]
    profile_picture_url = user.profile_picture.url(:large)
    if profile_picture_url.start_with? "/"
      "#{root_url}#{profile_picture_url[1..]}"
    else
      profile_picture_url
    end
  end
end
