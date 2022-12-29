# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :target, polymorphic: true

  class << self
    include CursorPaginatable

    define_cursor_paginator :cursored_for, :for
    define_cursor_paginator :cursored_for_type, :for_type

    def for(recipient, **kwargs)
      where(kwargs.merge!(recipient:)).order(:created_at).reverse_order
    end

    def for_type(recipient, type, **kwargs)
      where(kwargs.merge!(recipient:)).where(type:).order(:created_at).reverse_order
    end

    def notify(recipient, target)
      return nil unless target.respond_to? :notification_type

      notif_type = target.notification_type
      return nil unless notif_type

      make_notification(recipient, target, notif_type)
    end

    def denotify(recipient, target)
      return nil if recipient.blank?
      return nil unless target.respond_to? :notification_type

      notif_type = target.notification_type
      return nil unless notif_type

      notif = Notification.find_by(recipient:, target:)
      notif&.destroy
    end

    private

    def make_notification(recipient, target, notification_type)
      return if get_notification_owner(target).present? && recipient.muting?(get_notification_owner(target))

      n = notification_type.new(target:,
                                recipient:,
                                new:       true)
      n.save!
      n
    end

    def get_notification_owner(target)
      if target.is_a? User
        target
      elsif target.try(:user) && target.user.is_a?(User)
        target.user
      elsif target.try(:source) && target.source.is_a?(User)
        target.source
      end
    end
  end
end
