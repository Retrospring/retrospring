class Answer < ApplicationRecord
  extend Answer::TimelineMethods

  belongs_to :user, counter_cache: :answered_count
  belongs_to :question, counter_cache: :answer_count
  has_many :comments, dependent: :destroy
  has_many :smiles, class_name: "Appendable::Reaction", foreign_key: :parent_id, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :comment_smiles, through: :comments, source: :smiles

  # rubocop:disable Rails/UniqueValidationWithoutIndex
  # This cop is disabled here because there already are questions with
  # multiple answers. Adding an index would break things database-side
  validates :question_id, uniqueness: { scope: :user_id }
  # rubocop:enable Rails/UniqueValidationWithoutIndex

  scope :pinned, -> { where.not(pinned_at: nil) }

  SHORT_ANSWER_MAX_LENGTH = 640

  after_create do
    Inbox.where(user: self.user, question: self.question).destroy_all

    Notification.notify self.question.user, self unless self.question.user == self.user or self.question.user.nil?
    Subscription.subscribe self.user, self
    Subscription.subscribe self.question.user, self unless self.question.author_is_anonymous
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

    self.smiles.each do |smile|
      Notification.denotify self.user, smile
    end
    self.comments.each do |comment|
      Subscription.denotify comment, self
    end
    Notification.denotify question&.user, self
    Subscription.destruct self
  end

  def notification_type(*_args)
    Notification::QuestionAnswered
  end

  def long? = content.length > SHORT_ANSWER_MAX_LENGTH

  def pinned? = pinned_at.present?
end
