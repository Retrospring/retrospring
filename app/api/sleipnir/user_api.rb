class Sleipnir::UserAPI < Sleipnir::MountAPI
  include Sleipnir::Concerns

  helpers Sleipnir::Helpers

  namespace :user do
    desc "Current user's profile"
    oauth2 'public'
    throttle hourly: 72
    get "/", as: :user_api do
      represent current_user, with: Sleipnir::Entities::UserEntity, type: :full
    end

    desc "Specified user's profile picture"
    content_type :txt, 'text/plain'
    params do
      optional :redirect, type: Boolean, default: false
    end
    get "/:id/avatar", as: :user_profile_picture_api do
      avatar = user_avatar_for_id(params[:id])
      if params[:redirect]
        redirect avatar
      else
        if env['api.format'] == :txt
          avatar
        else
          {avatar: avatar}
        end
      end
    end

    desc "Specified user's profile header"
    content_type :txt, 'text/plain'
    params do
      optional :redirect, type: Boolean
    end
    get "/:id/header", as: :user_profile_picture_api do
      header = user_header_for_id(params[:id])
      if params[:redirect]
        redirect_to header
      else
        if env['api.format'] == :txt
          header
        else
          {header: header}
        end
      end
    end
  end
end
