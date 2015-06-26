class Sleipnir::Entities::AnswerEntity < Sleipnir::Entities::BaseEntity
  expose :id
  expose :_id, as: :id, if: :id_to_string do |object, _| object.id.to_s end

  expose :content, as: :answer

  expose :comment_count
  expose :smile_count

  expose :user_id, if: :no_answer_user
  expose :_user_id, as: :user_id, if: {id_to_string: true, no_answer_user: true} do |object, _| object.user_id.to_s end

  expose :user, with: Sleipnir::Entities::UserSlimEntity, unless: :no_answer_user

  # expose :question, if: :expose_question, unless: :nested do |object, options|
  #   options[:nested] = true
  #   Sleipnir::Entities::QuestionEntity.represent object.question, options
  # end

  # expose :comments, if: :expose_comments, unless: :nested do |object, options|
  #   options[:nested] = true
  #   Sleipnir::Entities::CommentEntity.represent object.comments, options
  # end

  expose :application, as: :created_with, with: Sleipnir::Entities::ApplicationReferenceEntity

  expose :created_at, format_with: :epochtime
  expose :_created_at, as: :created_at, if: :nanotime do |object, _| object.created_at.to_i * 1000 end
end
