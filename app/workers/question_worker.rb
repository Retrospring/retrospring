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
      next if skip_inbox?(f, question, user)

      inbox = Inbox.create(user_id: f.id, question_id:, new: true)
      f.push_notification(webpush_app, inbox) if webpush_app
    end
  rescue StandardError => e
    logger.info "failed to ask question: #{e.message}"
    Sentry.capture_exception(e)
  end

  private

  def skip_inbox?(follower, question, user)
    return true if follower.inbox_locked?
    return true if follower.banned?
    return true if muted?(follower, question)
    return true if user.muting?(question.user)
    return true if question.long? && !follower.profile.allow_long_questions

    false
  end

  def muted?(user, question)
    MuteRule.where(user:).any? { |rule| rule.applies_to? question }
  end
end
