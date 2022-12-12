# frozen_string_literal: true

require "exporter"

class ExportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :export, retry: 0

  # @param user_id [Integer] the user id
  def perform(user_id)
    user = User.find(user_id)

    exporter = Exporter.new(user)
    exporter.export

    Notification::DataExported.create(
      target_id:   user.id,
      target_type: "User::DataExport",
      recipient:   user,
      new:         true
    )
  end
end
