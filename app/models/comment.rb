class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :answer
  validates :user_id, presence: true
  validates :answer_id, presence: true

  validates :content, length: { maximum: 160 }

  after_create do
    Notification.notify answer.user, self unless answer.user == self.user
    user.increment! :commented_count
    answer.increment! :comment_count
  end

  before_destroy do
    Notification.denotify answer.user, self unless answer.user == self.user
    user.decrement! :commented_count
    answer.decrement! :comment_count
  end

  def notification_type(*_args)
    Notifications::Commented
  end
end
