class ShareWorker
  include Sidekiq::Worker

  sidekiq_options queue: :share, retry: 5

  # @param user_id [Integer] the user id
  # @param answer_id [Integer] the user id
  # @param service [String] the service to post to
  def perform(user_id, answer_id, service)
    service_type = "Services::#{service.camelize}"
    user_service = User.find(user_id).services.find_by(type: service_type)

    user_service.post(Answer.find(answer_id))
  rescue => e
    logger.info "failed to post answer #{answer_id} to #{service} for user #{user_id}: #{e.message}"
    NewRelic::Agent.notice_error(e)
    raise
  end
end
