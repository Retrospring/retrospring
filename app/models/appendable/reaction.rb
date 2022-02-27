# frozen_string_literal: true

class Appendable::Reaction < Appendable
  after_create do
    Notification.notify parent.user, self unless parent.user == user
    user.increment! :smiled_count
    parent.increment! :smile_count
  end

  before_destroy do
    Notification.denotify parent.user, self unless parent.user == user
    user.decrement! :smiled_count
    answer.decrement! :smile_count
  end

  def notification_type(*_args)
    Notifications::Smiled
  end
end
