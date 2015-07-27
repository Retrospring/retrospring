class DeletionWorker
  include Sidekiq::Worker

  sidekiq_options queue: :deletion, retry: false

  # @param resource_id [Integer] user id passed from Devise
  def perform(resource_id)
    begin
      User.find(resource_id).destroy!
    rescue => e
      logger.info "failed to delete user: #{e.message}"
    end
  end
end
