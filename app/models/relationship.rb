class Relationship < ActiveRecord::Base
  belongs_to :source, class_name: 'User'
  belongs_to :target, class_name: 'User'
  validates :source_id, presence: true
  validates :target_id, presence: true

  after_create do
    Notification.notify target, self

    # increment counts
    source.increment! :friend_count
    target.increment! :follower_count
  end

  before_destroy do
    Notification.denotify target, self

    # decrement counts
    source.decrement! :friend_count
    target.decrement! :follower_count
  end

  def notification_type(*_args)
    Notifications::StartedFollowing
  end
end
