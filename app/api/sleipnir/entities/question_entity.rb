class Sleipnir::Entities::QuestionEntity < Sleipnir::Entities::BaseEntity
  expose :id
  expose :_id, as: :id, if: :id_to_string do |object, _| object.id.to_s end

  expose :content, as: :question

  expose :answer_count

  expose :author_is_anonymous, as: :anonymous

  expose :user_id, safe: true

  expose :application, as: :created_with, with: Sleipnir::Entities::ApplicationReferenceEntity

  expose :created_at, format_with: :epochtime
  expose :_created_at, as: :created_at, if: :nanotime do |object, _| object.created_at.to_i * 1000 end

private

  def user_id()
    if object.author_is_anonymous
      -1
    else
      object.user_id
    end
  end
end
