class Sleipnir::Entities::UserEntity < Sleipnir::Entities::BaseEntity
  # https://github.com/intridea/grape-entity/issues/56 it was merged, then shortly after reverted
  expose :id, format_with: :strid

  expose :screen_name
  expose :display_name

  expose_image :profile_picture, :avatar
  expose_image :profile_header, :header
  expose :motivation_header
  expose :website
  expose :location
  expose :bio


  expose :flags do
    expose :admin
    expose :moderator
    expose :supporter
    expose :blogger
    expose :contributor
    expose :translator
    expose :app_developer
  end

  expose :banned do
    expose :banned

    expose :banned_until, as: :until, format_with: :nanotime

    expose :ban_reason, safe: true, as: :reason do |object| object.ban_reason || "" end
  end

  expose :locale

  expose :friend_count
  expose :follower_count
  expose :asked_count, as: :question_count
  expose :answered_count, as: :answer_count
  expose :commented_count, as: :comment_count
  expose :smiled_count, as: :smile_count
  expose :comment_smiled_count, as: :comment_smile_count

  expose :privacy_allow_anonymous_questions, as: :allow_anonymous_questions
  expose :privacy_allow_stranger_answers, as: :allow_stranger_answers

  with_options(if: {type: :full}) do
    expose :privacy_allow_public_timeline, as: :allow_public_timeline
    expose :privacy_show_in_search, as: :show_in_search
  end

  expose :created_at, as: :member_since, format_with: :nanotime

  class ProfilePictureProxy < Sleipnir::Entities::BaseEntity
    expose_image :profile_picture, :avatar
  end

  class ProfileHeaderProxy < Sleipnir::Entities::BaseEntity
    expose_image :profile_header, :header
  end

private

  def banned
    object.banned?
  end
end
