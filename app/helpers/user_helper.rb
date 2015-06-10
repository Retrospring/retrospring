module UserHelper
  # Decides what user name to show.
  # @return [String] The user name
  def user_screen_name(user, anonymous=false, url=true)
    return APP_CONFIG['anonymous_name'] if user.nil? || anonymous
    name = user.display_name.blank? ? user.screen_name : user.display_name
    return link_to(name, show_user_profile_path(user.screen_name), class: "#{"user--banned" if user.banned?}") if url
    name.strip
  end
end
