module UserHelper
  # Decides what user name to show.
  # @return [String] The user name
  def user_screen_name(user, anonymous: false, url: true, link_only: false)
    return APP_CONFIG['anonymous_name'] if user.nil? || anonymous
    name = user.profile.display_name.blank? ? user.screen_name : user.profile.display_name
    if url
      link = show_user_profile_path(user.screen_name)
      return link if link_only
      return link_to(name, link, class: "#{"user--banned" if user.banned?}")
    end
    name.strip
  end
end
