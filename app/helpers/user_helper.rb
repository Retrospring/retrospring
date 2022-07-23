# frozen_string_literal: true

module UserHelper
  # Decides what user name to show.
  # @param context_user [User] the user whose the profile preferences should be applied
  # @param author_identifier [nil, String] the author identifier of the question (questions only)
  # @return [String] The user name
  def user_screen_name(user, context_user: nil, author_identifier: nil, url: true, link_only: false)
    return unmask(user, context_user, author_identifier) if should_unmask?(author_identifier)
    return anonymous_name(context_user) if anonymous?(user, author_identifier.present?)

    if url
      return user_path(user) if link_only

      return profile_link(user)
    end
    user.profile.safe_name.strip
  end

  def moderation_view?
    current_user&.mod? && session[:moderation_view] == true
  end

  private

  def profile_link(user)
    link_to(user.profile.safe_name, user_path(user), class: ("user--banned" if user.banned?).to_s)
  end

  def should_unmask?(author_identifier)
    moderation_view? && author_identifier.present?
  end

  def unmask(user, context_user, author_identifier)
    return profile_link(user) if user.present?

    content_tag(:abbr, anonymous_name(context_user), title: author_identifier)
  end

  def anonymous_name(context_user)
    sanitize(context_user&.profile&.anon_display_name.presence || APP_CONFIG["anonymous_name"], tags: [])
  end

  def anonymous?(user, author_identifier)
    user.nil? || author_identifier.present?
  end
end
