module FeedbackHelper
  def canny_token
    return if current_user.nil?
    
    userData = {
      avatarURL: current_user.profile_picture.url(:large),
      name: current_user.screen_name,
      id: current_user.id,
      email: current_user.email
    }

    JWT.encode(userData, APP_CONFIG.dig("canny", "sso"))
  end
end