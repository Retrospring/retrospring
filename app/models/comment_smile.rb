class CommentSmile < ApplicationRecord
  belongs_to :user
  belongs_to :comment
  validates :user_id, presence: true, uniqueness: { scope: :comment_id, message: "already smiled comment" }
  validates :comment_id, presence: true

  after_create do
    Notification.notify comment.user, self unless comment.user == user
    user.increment! :comment_smiled_count
    comment.increment! :smile_count
  end

  before_destroy do
    Notification.denotify comment.user, self unless comment.user == user
    user.decrement! :comment_smiled_count
    comment.decrement! :smile_count
  end

  def notification_type(*_args)
    Notifications::CommentSmiled
  end
end
