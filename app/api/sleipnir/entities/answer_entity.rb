class Sleipnir::Entities::AnswerEntity < Sleipnir::Entities::BaseEntity
  expose :id, format_with: :strid

  expose :content, as: :answer

  expose :comment_count
  expose :smile_count

  expose :user_id, format_with: :strid, if: :no_answer_user

  expose :user, with: Sleipnir::Entities::UserSlimEntity, unless: :no_answer_user

  expose :question, with: Sleipnir::Entities::QuestionEntity

  expose :subscribed, if: :current_user_id

  expose :application, as: :created_with, with: Sleipnir::Entities::ApplicationReferenceEntity

  expose :created_at, format_with: :nanotime

private

  def subscribed
    return false if options[:current_user_id].nil?
    not object.subscriptions.find_by(user_id: options[:current_user_id]).nil?
  end
end
