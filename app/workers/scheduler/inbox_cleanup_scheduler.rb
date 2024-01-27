# frozen_string_literal: true

class Scheduler::InboxCleanupScheduler
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
    orphaned_entries = InboxEntry.where(question_id: nil).includes(:user)
    orphaned_entries.each do |inbox|
      logger.info "Deleting orphaned inbox entry #{inbox.id} from user #{inbox.user.id}"
      inbox.destroy
    end
  end
end
