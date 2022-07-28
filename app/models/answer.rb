class Answer < ApplicationRecord
  include Discard::Model
  extend Answer::TimelineMethods

  belongs_to :user
  belongs_to :question
  has_many :comments, dependent: :destroy
  has_many :smiles, class_name: "Appendable::Reaction", foreign_key: :parent_id, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :comment_smiles, through: :comments, source: :smiles

  # rubocop:disable Rails/SkipsModelValidations
  after_create do
    Inbox.where(user: self.user, question: self.question).destroy_all

    Notification.notify self.question.user, self unless self.question.user == self.user or self.question.user.nil?
    Subscription.subscribe self.user, self
    Subscription.subscribe self.question.user, self unless self.question.author_is_anonymous
    user.increment! :answered_count
    question.increment! :answer_count
  end

  before_destroy do
    # mark a report as deleted if it exists
    rep = Report.where(target_id: id, type: "Reports::Answer")
    rep.each do |r|
      unless r.nil?
        r.deleted = true
        r.save
      end
    end

    user&.decrement! :answered_count
    question&.decrement! :answer_count
    self.smiles.each do |smile|
      Notification.denotify self.user, smile
    end
    self.comments.each do |comment|
      comment.user&.decrement! :commented_count
      Subscription.denotify comment, self
    end
    Notification.denotify question&.user, self
    Subscription.destruct self
  end
  # rubocop:enable Rails/SkipsModelValidations

  def notification_type(*_args)
    Notification::QuestionAnswered
  end
end
