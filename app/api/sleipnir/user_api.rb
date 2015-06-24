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

    desc "Current user's inbox"
    oauth2 'public'
    throttle hourly: 720
    get "/inbox", as: :inbox_api do
      collection = since_id Inbox, "user_id = ?", [current_user.id]
      represent_collection collection, with: Sleipnir::Entities::InboxesEntity
    end

    desc "Current user's notifications"
    oauth2 'public'
    throttle hourly: 720
    get "/notifications", as: :notification_api do
      collection = since_id Notification, "recipient_id = ?", [current_user.id]
      represent_collection collection, with: Sleipnir::Entities::NotificationsEntity
    end

    desc "Given user's profile"
    # oauth2 'public'
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
      represent_collection collection, with: Sleipnir::Entities::QuestionsEntity, no_question_user: true
    end

    desc "Given user's answers"
    # oauth2 'public'
    throttle hourly: 720
    get "/:id/answers", as: :user_answers_api do
      collection = since_id Answer, "user_id = ?", [params[:id]]
      represent_collection collection, with: Sleipnir::Entities::AnswersEntity, no_answer_user: true
    end

    desc "Given user's followers"
    # oauth2 'public'
    throttle hourly: 72
    get "/:id/followers", as: :user_followers_api do
      collection = since_id Relationship, "target_id = ?", [params[:id]]
      represent_collection collection, with: Sleipnir::Entities::RelationshipsEntity, relationship: :them
    end

    desc "Given user's following"
    # oauth2 'public'
    throttle hourly: 72
    get "/:id/following", as: :user_following_api do
      collection = since_id Relationship, "source_id = ?", [params[:id]]
      represent_collection collection, with: Sleipnir::Entities::RelationshipsEntity, relationship: :me
    end

    desc "Follow given user"
    oauth2 'write'
    throttle hourly: 72
    post "/:id/follow", as: :user_follow_api do
      begin
        user = User.find(params["id"])
        if user.nil?
          status 404
          return present({success: false, code: 404, reason: "Cannot find user #{params["id"]}"})
        end
        current_user.follow(user)
        present({success: true, code: 200, reason: "Followed user #{params["id"]}"})
      rescue
        status 403
        present({success: false, code: 503, reason: "Already following user"})
      end
    end

    desc "Unfollow given user"
    oauth2 'write'
    throttle hourly: 72
    delete "/:id/follow", as: :user_unfollow_api do
      begin
        user = User.find(params["id"])
        if user.nil?
          status 404
          return present({success: false, code: 404, reason: "Cannot find user #{params["id"]}"})
        end
        current_user.unfollow(user)
        present({success: true, code: 200, reason: "Unfollowed user #{params["id"]}"})
      rescue
        status 403
        present({success: false, code: 403, reason: "Not following user"})
      end
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
