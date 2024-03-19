class Answer < ApplicationRecord
  extend Answer::TimelineMethods

  attr_accessor :has_reacted, :is_subscribed

  belongs_to :user, counter_cache: :answered_count
  belongs_to :question, counter_cache: :answer_count
  has_many :comments, dependent: :destroy
  has_many :smiles, class_name: "Reaction", foreign_key: :parent_id, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :comment_smiles, through: :comments, source: :smiles

  # rubocop:disable Rails/UniqueValidationWithoutIndex
  # This cop is disabled here because there already are questions with
  # multiple answers. Adding an index would break things database-side
  validates :question_id, uniqueness: { scope: :user_id }
  # rubocop:enable Rails/UniqueValidationWithoutIndex

  scope :pinned, -> { where.not(pinned_at: nil) }
  scope :for_user, lambda { |current_user|
    next select("answers.*", "false as is_subscribed", "false as has_reacted") if current_user.nil?

    select("answers.*",
           "EXISTS(SELECT 1
              FROM subscriptions
              WHERE answer_id = answers.id
                AND user_id = #{current_user.id}) as is_subscribed",
           "EXISTS(SELECT 1
              FROM reactions
              WHERE parent_id = answers.id
                AND parent_type = 'Answer'
                AND user_id = #{current_user.id}) as has_reacted",
           )
  }

  SHORT_ANSWER_MAX_LENGTH = 640

  after_create do
    InboxEntry.where(user: self.user, question: self.question).destroy_all
    user.touch :inbox_updated_at # rubocop:disable Rails/SkipsModelValidations

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

  def has_reacted = self.attributes["has_reacted"] || false

  def is_subscribed = self.attributes["is_subscribed"] || false
end
