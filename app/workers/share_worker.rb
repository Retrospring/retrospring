class ShareWorker
  include Sidekiq::Worker

  sidekiq_options queue: :share, retry: false

  # @param user_id [Integer] the user id
  # @param answer_id [Integer] the user id
  # @param services [Array] array containing strings
  def perform(user_id, answer_id, services)
    User.find(user_id).services.each do |service|
      begin
        service.post(Answer.find(answer_id)) if services.include? service.provider
      rescue => e
        logger.info "failed to post answer #{answer_id} to #{service.provider} for user #{user_id}: #{e.message}"
      end
    end
  end
end
