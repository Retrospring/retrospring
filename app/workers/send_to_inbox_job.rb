# frozen_string_literal: true

class SendToInboxJob
  include Sidekiq::Job

  sidekiq_options queue: :question, retry: false

  # @param follower_id [Integer] user id passed from Devise
  # @param question_id [Integer] newly created question id
  def perform(follower_id, question_id)
  end
end
