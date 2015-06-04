class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
  has_many :comments, dependent: :destroy
  has_many :smiles, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :comment_smiles, through: :comments, source: :smiles
  belongs_to :application, class_name: "Doorkeeper::Application"

  after_create do
    Inbox.where(user: self.user, question: self.question).destroy_all

    Notification.notify self.question.user, self unless self.question.user == self.user or self.question.user.nil?
    Subscription.subscribe self.user, self
    Subscription.subscribe self.question.user, self unless self.question.author_is_anonymous
    self.user.increment! :answered_count
    self.question.increment! :answer_count
  end

  before_destroy do
    # mark a report as deleted if it exists
    rep = Report.where(target_id: self.id, type: 'Reports::Answer')
    rep.each do |r|
      unless r.nil?
        r.deleted = true
        r.save
      end
    end

    self.user.decrement! :answered_count
    self.question.decrement! :answer_count
    self.smiles.each do |smile|
      Notification.denotify self.user, smile
    end
    self.comments.each do |comment|
      comment.user.decrement! :commented_count
      Subscription.denotify comment, self
    end
    Notification.denotify self.question.user, self
    Subscription.destruct self
  end

  def notification_type(*_args)
    Notifications::QuestionAnswered
  end
end
