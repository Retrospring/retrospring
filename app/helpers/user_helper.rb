# frozen_string_literal: true

module UserHelper
  # Decides what user name to show.
  # @param context_user [User] the user whose the profile preferences should be applied
  # @return [String] The user name
  def user_screen_name(user, context_user: nil, anonymous: false, url: true, link_only: false)
    return profile_link(user) if should_unmask?(user, anonymous)
    return anonymous_name(context_user) if anonymous?(user, anonymous)

    if url
      return show_user_profile_path(user.screen_name) if link_only

      return profile_link(user)
    end
    user.profile.safe_name.strip
  end

  private

  def profile_link(user)
    link_to(user.profile.safe_name, show_user_profile_path(user.screen_name), class: ("user--banned" if user.banned?).to_s)
  end

  def should_unmask?(user, anonymous)
    user.present? && moderation_view? && anonymous
  end

  def anonymous_name(context_user)
    sanitize(context_user&.profile&.anon_display_name.presence || APP_CONFIG["anonymous_name"], tags: [])
  end

  def anonymous?(user, anonymous)
    user.nil? || anonymous
  end
end
