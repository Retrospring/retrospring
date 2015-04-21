class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :answer
  validates :user_id, presence: true
  validates :answer_id, presence: true

  validates :content, length: { maximum: 160 }

  after_create do
    Subscription.subscribe self.user, answer
    Subscription.notify self, answer
    user.increment! :commented_count
    answer.increment! :comment_count
  end

  before_destroy do
    Subscription.denotify self, answer
    user.decrement!  :commented_count
    answer.decrement! :comment_count
  end

  def notification_type(*_args)
    Notifications::Commented
  end
end
