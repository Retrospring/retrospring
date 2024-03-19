# frozen_string_literal: true

class Reaction < ApplicationRecord
  belongs_to :parent, polymorphic: true
  belongs_to :user

  validates :parent_id, uniqueness: { scope: :user_id }

  # rubocop:disable Rails/SkipsModelValidations
  after_create do
    Notification.notify parent.user, self unless parent.user == user
    user.increment! :smiled_count
    parent.increment! :smile_count
  end

  before_destroy do
    Notification.denotify parent&.user, self
    user&.decrement! :smiled_count
    parent&.decrement! :smile_count
  end
  # rubocop:enable Rails/SkipsModelValidations

  def notification_type(*_args)
    return Notification::CommentSmiled if parent.instance_of?(Comment)

    Notification::Smiled
  end
end
