# frozen_string_literal: true

class QuestionWorker
  include Sidekiq::Worker

  sidekiq_options queue: :question, retry: false

  # @param user_id [Integer] user id passed from Devise
  # @param question_id [Integer] newly created question id
  def perform(user_id, question_id)
    user = User.find(user_id)
    question = Question.find(question_id)
    webpush_app = Rpush::App.find_by(name: "webpush")

    user.followers.each do |f|
      next if f.inbox_locked?
      next if f.banned?
      next if MuteRule.where(user: f).any? { |rule| rule.applies_to? question }
      next if user.muting?(question.user)

      Inbox.create(user_id: f.id, question_id: question_id, new: true)

      f.web_push_subscriptions.each do |s|
        n = Rpush::Webpush::Notification.new
        n.app = webpush_app
        n.registration_ids = [s.subscription.symbolize_keys]
        n.data = { message: { title: "New question notif title", body: question.content }.to_json }
        n.save!
      end
    end
  rescue StandardError => e
    logger.info "failed to ask question: #{e.message}"
    Sentry.capture_exception(e)
  end
end
