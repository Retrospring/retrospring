# frozen_string_literal: true

class QuestionWorker
  include Sidekiq::Worker

  sidekiq_options queue: :question, retry: false

  # @param user_id [Integer] user id passed from Devise
  # @param question_id [Integer] newly created question id
  def perform(user_id, question_id)
    user = User.find(user_id)

    user.followers.each do |f|
      Inbox.create(user_id: f.id, question_id: question_id, new: true)
    end
  rescue StandardError => e
    logger.info "failed to ask question: #{e.message}"
    Sentry.capture_exception(e)
  end
end
