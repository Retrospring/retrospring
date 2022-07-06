require 'exporter'
class ExportWorker
  include Sidekiq::Worker

  sidekiq_options queue: :export, retry: 0

  # @param user_id [Integer] the user id
  def perform(user_id)
    exporter = Exporter.new User.find(user_id)
    exporter.export
    question = Question.create(content: "Your #{APP_CONFIG['site_name']} data export is ready!  You can download it " +
        "from the settings page under the \"Export\" tab.", author_is_anonymous: true,
                               author_identifier: "retrospring_exporter")
    Inbox.create(user_id: user_id, question_id: question.id, new: true)
  end
end
