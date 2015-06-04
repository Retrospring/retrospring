class Sleipnir::UserAPI < Sleipnir::MountAPI
  include Sleipnir::Concerns

  helpers Sleipnir::Helpers

  namespace :user do
    desc "Current user's profile"
    oauth2 'public'
    throttle hourly: 72
    get "/me", as: :user_api do
      represent current_user, with: Sleipnir::Entities::UserEntity, type: :full
    end

    desc "Given user's profile"
    oauth2 'public'
    throttle hourly: 72
    get "/:id/profile", as: :given_user_api do
      represent User.find(params[:id]), with: Sleipnir::Entities::UserEntity
    end

    desc "Given user's questions"
    # oauth2 'public'
    throttle hourly: 720
    params do
      optional :since_id, type: Fixnum
    end
    get "/:id/questions", as: :user_questions_api do
      collection = since_id Question, "author_is_anonymous = FALSE AND user_id = ?", [params[:id]]
      represent_collection collection, with: Sleipnir::Entities::QuestionsEntity 
    end

    desc "Given user's answers"
    oauth2 'public'
    throttle hourly: 720
    get "/:id/questions", as: :user_answers_api do
      throw new TeapotError
    end

    desc "Given user's followers"
    oauth2 'public'
    throttle hourly: 72
    get "/:id/questions", as: :user_followers_api do
      throw new TeapotError
    end

    desc "Given user's following"
    oauth2 'public'
    throttle hourly: 72
    get "/:id/questions", as: :user_following_api do
      throw new TeapotError
    end

    desc "Specified user's profile picture"
    content_type :txt, 'text/plain'
    params do
      optional :redirect, type: Boolean, default: false
      optional :size, type: String, default: "medium"
    end
    get "/:id/avatar", as: :user_profile_picture_api do
      if params[:size] == "original"
        params[:size] = "small" # no
      end

      if params[:redirect]
        redirect user_avatar_for_id(params[:id], params[:size])
      else
        if env['api.format'] == :txt
          user_avatar_for_id(params[:id], params[:size])
        else
          # doesn't work??
          # present User.find(params[:id]), with: Sleipnir::Entities::UserEntity, only: [:profile_header, :header]
          present User.find(params[:id]), with: Sleipnir::Entities::UserEntity::ProfilePictureProxy
        end
      end
    end

    desc "Specified user's profile header"
    content_type :txt, 'text/plain'
    params do
      optional :redirect, type: Boolean, default: false
      optional :size, type: String, default: "web"
    end
    get "/:id/header", as: :user_profile_picture_api do
      if params[:size] == "original"
        params[:size] = "mobile" # no
      end

      if params[:redirect]
        redirect user_header_for_id(params[:id], params[:size])
      else
        if env['api.format'] == :txt
          user_header_for_id(params[:id], params[:size])
        else
          # present User.find(params[:id]), with: Sleipnir::Entities::UserEntity, only: [:profile_picture, :avatar]
          present User.find(params[:id]), with: Sleipnir::Entities::UserEntity::ProfileHeaderProxy
        end
      end
    end
  end
end
