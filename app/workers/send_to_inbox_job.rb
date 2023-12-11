# frozen_string_literal: true

class SendToInboxJob
  include Sidekiq::Job

  sidekiq_options queue: :question, retry: false

  # @param follower_id [Integer] user id passed from Devise
  # @param question_id [Integer] newly created question id
  def perform(follower_id, question_id)
    follower = User.includes(:web_push_subscriptions, :mute_rules, :muted_users).find(follower_id)
    question = Question.includes(:user).find(question_id)
    webpush_app = Rpush::App.find_by(name: "webpush")

    return if skip_inbox?(follower, question)

    inbox = Inbox.create(user_id: follower.id, question_id:, new: true)
    follower.push_notification(webpush_app, inbox) if webpush_app
  end

  private

  def skip_inbox?(follower, question)
    return true if follower.inbox_locked?
    return true if follower.banned?
    return true if muted?(follower, question)
    return true if follower.muting?(question.user)
    return true if question.long? && !follower.profile.allow_long_questions

    false
  end

  # @param [User] user
  # @param [Question] question
  def muted?(user, question) = user.mute_rules.any? { |rule| rule.applies_to? question }
end
