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

    desc "Current user's timeline"
    oauth2 'public'
    throttle hourly: 72
    get "/timeline", as: :timeline_api do
      collection = since_id Answer, 'user_id in (?) OR user_id = ?', [current_user.friend_ids, current_user.id]
      represent_collection collection, with: Sleipnir::Entities::AnswersEntity
    end

    desc "Public timeline"
    throttle hourly: 72
    get "/public", as: :timeline_api do
      collection = since_id Answer.joins(:user), '"users"."privacy_allow_public_timeline" = ?', [true]
      represent_collection collection, with: Sleipnir::Entities::AnswersEntity
    end

    desc "Current user's new numbers"
    oauth2 'public'
    throttle hourly: 144
    get "/new", as: :count_api do
      present({success: true, code: 200, result: {inbox: new_inbox_count, notification: new_notification_count}})
    end

    desc "Current user's inbox"
    oauth2 'public'
    throttle hourly: 720
    params do
      optional :mark_as_read, type: Boolean, default: false
    end
    get "/inbox", as: :inbox_api do
      collection = since_id Inbox, "user_id = ?", [current_user.id]
      represent_collection collection, with: Sleipnir::Entities::InboxesEntity
      if params[:mark_as_read] and current_scopes.has_scopes?(['write'])
        collection.update_all new: false
      end
    end

    desc "Current user's notifications"
    oauth2 'public'
    throttle hourly: 720
    params do
      optional :mark_as_read, type: Boolean, default: false
    end
    get "/notifications", as: :notification_api do
      collection = since_id Notification, "recipient_id = ?", [current_user.id]
      represent_collection collection, with: Sleipnir::Entities::NotificationsEntity
      if params[:mark_as_read] and current_scopes.has_scopes?(['write'])
        collection.update_all new: false
      end
    end

    desc "Mark notification as read"
    oauth2 'write'
    throttle hourly: 14400
    patch '/notifications/:id', as: :mark_notification_read_api do
      entry = Notification.find(params[:id])
      if entry.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_NOTIF_NOT_FOUND"})
      end

      if entry.recipient_id != current_user.id
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_PRIV"})
      end

      entry.update new: false
      status 205
      return present({success: true, code: 205, result: "NOTIF_READ"})
    end

    desc "Mark inbox as read"
    oauth2 'write'
    throttle hourly: 14400
    patch '/inbox/:id', as: :mark_inbox_read_api do
      entry = Inbox.find(params[:id])
      if entry.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_INBOX_NOT_FOUND"})
      end

      if entry.user_id != current_user.id
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_PRIV"})
      end

      entry.update new: false
      status 205
      return present({success: true, code: 205, result: "INBOX_READ"})
    end

    desc "Delete entries from a user's inbox"
    oauth2 'write'
    throttle hourly: 720
    params do
      optional :all, type: Boolean, default: false
    end
    delete '/inbox', as: :batch_delete_inbox_api do
      collection = if params[:all]
        current_user.inboxes.all
      else
        current_user.inboxes.where new: false
      end

      collection.delete_all

      status 204
      return
    end

    desc "Delete entry from a user's inbox"
    oauth2 'write'
    throttle hourly: 720
    params do
      optional :all, type: Boolean, default: false
    end
    delete '/inbox/:id', as: :delete_inbox_api do
      entry = Inbox.find(params[:id])
      if entry.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_INBOX_NOT_FOUND"})
      end

      if entry.user_id != current_user.id
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_PRIV"})
      end

      entry.destroy
      status 204
      return
    end

    desc "Given user's profile"
    throttle hourly: 72
    get "/:id/profile", as: :given_user_api do
      represent User.find(params[:id]), with: Sleipnir::Entities::UserEntity
    end

    desc "Given user's questions"
    throttle hourly: 720
    params do
      optional :since_id, type: Fixnum
    end
    get "/:id/questions", as: :user_questions_api do
      collection = since_id Question, "author_is_anonymous = FALSE AND user_id = ?", [params[:id]]
      represent_collection collection, with: Sleipnir::Entities::QuestionsEntity
    end

    desc "Given user's answers"
    throttle hourly: 720
    get "/:id/answers", as: :user_answers_api do
      collection = since_id Answer, "user_id = ?", [params[:id]]
      represent_collection collection, with: Sleipnir::Entities::AnswersEntity
    end

    desc "Given user's followers"
    throttle hourly: 72
    get "/:id/followers", as: :user_followers_api do
      collection = since_id Relationship, "target_id = ?", [params[:id]]
      represent_collection collection, with: Sleipnir::Entities::FollowersEntity, relationship: :them
    end

    desc "Given user's following"
    throttle hourly: 72
    get "/:id/following", as: :user_following_api do
      collection = since_id Relationship, "source_id = ?", [params[:id]]
      represent_collection collection, with: Sleipnir::Entities::FollowingsEntity, relationship: :me
    end

    desc "Ask all your followers a question"
    oauth2 'write'
    throttle hourly: 360
    params do
      requires :question, type: String
      optional :anonymous, type: Boolean, default: false
    end
    post "/me/ask", as: :follower_question_api do
        question = Question.create!(content: params[:question],
                                    application: current_application,
                                    author_is_anonymous: params[:anonymous],
                                    user: current_user)

        current_user.increment! :asked_count unless params[:anonymous]

        current_user.followers.each do |f|
          next if params[:anonymous] and not f.privacy_allow_anonymous_questions
          Inbox.create!(user: f, question: question, new: true)
        end

        status 201
        present({success: true, code: 201, result: "SUCCESS_ASKED_ALL"})
    end

    desc "Ask user a question"
    throttle hourly: 360
    params do
      requires :question, type: String
      optional :anonymous, type: Boolean, default: false
    end
    post '/:id/ask', as: :ask_user_question_api do
      target = User.find params[:id]
      if target.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_USER_NOT_FOUND"})
      end

      if params[:anonymous] and not target.privacy_allow_anonymous_questions
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_ANONY"})
      end

      question = Question.create!(content: params[:question],
                                  application: current_application,
                                  author_is_anonymous: params[:anonymous],
                                  user: current_user)

      unless current_user.nil?
        current_user.increment! :asked_count unless params[:anonymous]
      end

      Inbox.create!(user: target, question: question, new: true)

      status 201
      present({success: true, code: 201, result: "SUCCESS_ASKED"})
    end

    desc "Follow given user"
    oauth2 'write'
    throttle hourly: 72
    post "/:id/follow", as: :user_follow_api do
      begin
        user = User.find(params[:id])
        if user.nil?
          status 404
          return present({success: false, code: 404, result: "ERR_USER_NOT_FOUND"})
        end
        current_user.follow(user)
        status 201
        present({success: true, code: 201, result: "SUCCESS_FOLLOWED"})
      rescue
        status 403
        present({success: false, code: 403, result: "ERR_ALREADY_FOLLOWING"})
      end
    end

    desc "Unfollow given user"
    oauth2 'write'
    throttle hourly: 72
    delete "/:id/follow", as: :user_unfollow_api do
      begin
        user = User.find(params[:id])
        if user.nil?
          status 404
          return present({success: false, code: 404, result: "ERR_USER_NOT_FOUND"})
        end
        status 204
        return
      rescue
        status 403
        present({success: false, code: 403, result: "ERR_NOT_FOLLOWING"})
      end
    end

    desc "Specified user's profile picture"
    content_type :txt, 'text/plain'
    params do
      optional :redirect, type: Boolean, default: false
      optional :size, type: String, default: "medium"
    end
    get "/:id/avatar", as: :user_profile_picture_api do
      if params[:redirect]
        redirect user_avatar_for_id(params[:id], params[:size])
      else
        if env['api.format'] == :txt
          user_avatar_for_id(params[:id], params[:size])
        else
          represent User.find(params[:id]), with: Sleipnir::Entities::UserEntity::ProfilePictureProxy
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
      if params[:redirect]
        redirect user_header_for_id(params[:id], params[:size])
      else
        if env['api.format'] == :txt
          user_header_for_id(params[:id], params[:size])
        else
          represent User.find(params[:id]), with: Sleipnir::Entities::UserEntity::ProfileHeaderProxy
        end
      end
    end

    desc "Ban specified user"
    oauth2 'moderation'
    params do
      optional :reason, type: String, default: nil
      optional :until, type: Fixnum, default: nil
    end
    post '/:id/ban', as: :ban_user_api do
      unless current_user.mod?
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_PRIV"})
      end

      target = User.find(params[:id])

      target.ban params[:until], params[:reason]

      status 201
      present({success: true, code: 201, result: "USER_BANNED"})
    end

    desc "Unban specified user"
    oauth2 'moderation'
    delete '/:id/ban', as: :unban_user_api do
      unless current_user.mod?
        status 403
        return present({success: false, code: 403, result: "ERR_USER_NO_PRIV"})
      end

      target = User.find(params[:id])

      target.unban

      status 204
      return
    end
  end
end
