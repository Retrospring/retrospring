class Sleipnir::Entities::QuestionEntity < Sleipnir::Entities::BaseEntity
  expose :id
  expose :_id, as: :id, if: :id_to_string do |object, _| object.id.to_s end

  expose :content, as: :question

  expose :answer_count

  expose :author_is_anonymous, as: :anonymous

  expose :user_id, if: :no_question_user
  expose :_user_id, as: :user_id, if: {id_to_string: true, no_question_user: true} do |object, _| user_id.to_s end

  expose :user, with: Sleipnir::Entities::UserSlimEntity, unless: :no_question_user

  expose :application, as: :created_with, with: Sleipnir::Entities::ApplicationReferenceEntity

  expose :created_at, format_with: :epochtime
  expose :_created_at, as: :created_at, if: :nanotime do |object, _| object.created_at.to_i * 1000 end

private

  def user_id()
    if object.author_is_anonymous
      nil
    else
      object.user_id
    end
  end
end
