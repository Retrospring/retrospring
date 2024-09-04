# frozen_string_literal: true

class ExportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :export, retry: 0

  # @param user_id [Integer] the user id
  def perform(user_id)
  end
end
