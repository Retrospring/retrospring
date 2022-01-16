# frozen_string_literal: true

class Relationships::Follow < Relationship
  after_create do
    Notification.notify target, self
  end

  before_destroy do
    Notification.denotify target, self
  end

  def notification_type(*_args)
    Notifications::StartedFollowing
  end
end
