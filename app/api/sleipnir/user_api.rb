class Sleipnir::UserAPI < Sleipnir::MountAPI
  include Sleipnir::Concerns

  helpers Sleipnir::Helpers

  namespace :user do
    desc "Current user's profile"
    oauth2 'public'
    throttle hourly: 72
    get "/", as: :user_api do
      raise TeapotError.new
    end

    desc "Specified user's profile picture"
    get "/:id/avatar", as: :user_profile_picture_api do
      avatar = user_avatar_for_id(params[:id])
      if env['api.format'] == :txt
        avatar
      else
        {avatar: avatar}
      end
    end

    desc "Specified user's profile header"
    get "/:id/header", as: :user_profile_picture_api do
      header = user_header_for_id(params[:id])
      if env['api.format'] == :txt
        header
      else
        {header: header}
      end
    end
  end
end
