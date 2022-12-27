# frozen_string_literal: true

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
  rescue ActiveRecord::RecordNotFound
    logger.info "Tried to post answer ##{answer_id} for user ##{user_id} to #{service.titleize} but the user/answer/service did not exist (likely deleted), will not retry."
    # The question to be posted was deleted
    nil
  rescue Twitter::Error::DuplicateStatus
    logger.info "Tried to post answer ##{answer_id} from user ##{user_id} to Twitter but the status was already posted."
    nil
  rescue Twitter::Error::Forbidden
    # User's Twitter account is suspended
    logger.info "Tried to post answer ##{answer_id} from user ##{user_id} to Twitter but the account is suspended."
    nil
  rescue Twitter::Error::Unauthorized
    # User's Twitter token has expired or been revoked
    # TODO: Notify user if this happens (https://github.com/Retrospring/retrospring/issues/123)
    logger.info "Tried to post answer ##{answer_id} from user ##{user_id} to Twitter but the token has exired or been revoked."
    nil
  rescue => e
    logger.info "failed to post answer #{answer_id} to #{service} for user #{user_id}: #{e.message}"
    Sentry.capture_exception(e)
    raise
  end
end
