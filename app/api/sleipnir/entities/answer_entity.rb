class Sleipnir::Entities::AnswerEntity < Sleipnir::Entities::BaseEntity
  expose :id
  expose :_id, as: :id, if: :id_to_string do |object, _| object.id.to_s end

  expose :content, as: :answer

  expose :comment_count
  expose :smile_count

  expose :user_id, if: :no_answer_user
  expose :_user_id, as: :user_id, if: {id_to_string: true, no_answer_user: true} do |object, _| object.user_id.to_s end

  expose :user, with: Sleipnir::Entities::UserSlimEntity, unless: :no_answer_user

  expose :question_id

  expose :subscribed, if: :current_user_id

  expose :application, as: :created_with, with: Sleipnir::Entities::ApplicationReferenceEntity

  expose :created_at, format_with: :epochtime
  expose :_created_at, as: :created_at, if: :nanotime do |object, _| object.created_at.to_i * 1000 ends

private

  def subscribed
    return false if options[:current_user_id].nil?
    not object.subscriptions.find_by(user_id: options[:current_user_id]).nil?
  end
end
