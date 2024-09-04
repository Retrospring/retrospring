# frozen_string_literal: true

# @deprecated This is to be replaced by SendToInboxJob. Remaining here so that remaining QuestionWorker jobs can finish.
class QuestionWorker
  include Sidekiq::Worker

  sidekiq_options queue: :question, retry: false

  # @param user_id [Integer] user id passed from Devise
  # @param question_id [Integer] newly created question id
  def perform(user_id, question_id)
  end
end
