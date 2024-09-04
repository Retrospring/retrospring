# frozen_string_literal: true

class Scheduler::InboxCleanupScheduler
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform
  end
end
