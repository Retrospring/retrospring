module UserHelper
  # Decides what user name to show.
  # @param context_user [User] the user whose the profile preferences should be applied
  # @return [String] The user name
  def user_screen_name(user, context_user: nil, anonymous: false, url: true, link_only: false)
    return anonymous_name(context_user) if user.nil? || anonymous

    name = user.profile.display_name.presence || user.screen_name
    if url
      link = show_user_profile_path(user.screen_name)
      return link if link_only

      return link_to(name, link, class: ("user--banned" if user.banned?).to_s)
    end
    name.strip
  end

  private

  def anonymous_name(context_user)
    context_user&.profile&.anon_display_name.presence || APP_CONFIG["anonymous_name"]
  end
end
