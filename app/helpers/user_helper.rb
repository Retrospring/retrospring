module UserHelper
  # Decides what user name to show.
  # @return [String] The user name
  def user_screen_name(user, anonymous=false)
    return APP_CONFIG['anonymous_name'] if user.nil? || anonymous
    return user.display_name unless user.display_name.blank?
    user.screen_name
  end
end
