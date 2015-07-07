class Sleipnir::Entities::QuestionEntity < Sleipnir::Entities::BaseEntity
  expose :id, format_with: :strid

  expose :content, as: :question

  expose :answer_count

  expose :author_is_anonymous, as: :anonymous

  expose :user_id, format_with: :strid, if: :no_question_user

  expose :user, with: Sleipnir::Entities::UserSlimEntity, unless: :no_question_user

  expose :application, as: :created_with, with: Sleipnir::Entities::ApplicationReferenceEntity

  expose :created_at, format_with: :nanotime

private

  def user_id
    options[:force_identity] = false if options[:force_identity].nil?

    unless object.author_is_anonymous and not options[:force_identity]
      object.user_id
    else
      nil
    end
  end

  def user
    options[:force_identity] = false if options[:force_identity].nil?

    unless object.author_is_anonymous and not options[:force_identity]
      object.user
    else
      nil
    end
  end
end
