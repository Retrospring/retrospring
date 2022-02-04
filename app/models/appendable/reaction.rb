# frozen_string_literal: true

class Appendable::Reaction < Appendable
  # rubocop:disable Rails/SkipsModelValidations
  after_create do
    Notification.notify parent.user, self unless parent.user == user
    user.increment! :smiled_count
    parent.increment! :smile_count
  end

  before_destroy do
    Notification.denotify parent.user, self
    user&.decrement! :smiled_count
    parent&.decrement! :smile_count
  end
  # rubocop:enable Rails/SkipsModelValidations

  def notification_type(*_args)
    Notifications::Smiled
  end
end
