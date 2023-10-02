# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :answer

  class << self
    def subscribe(recipient, target)
      existing = Subscription.find_by(user: recipient, answer: target)
      return true if existing.present?

      Subscription.create!(user: recipient, answer: target)
    end

    def unsubscribe(recipient, target)
      return nil if recipient.nil? || target.nil?

      subs = Subscription.find_by(user: recipient, answer: target)
      subs&.destroy
    end

    def destruct(target)
      return nil if target.nil?

      Subscription.where(answer: target).destroy_all
    end

    def notify(source, target)
      return nil if source.nil? || target.nil?

      # As we will need to notify for each person subscribed,
      # it's much faster to bulk insert than to use +Notification.notify+
      notifications = Subscription.for(source, target).pluck(:user_id).map do |recipient_id|
        {
          target_id:    source.id,
          target_type:  Comment,
          recipient_id:,
          new:          true,
          type:         Notification::Commented,
          created_at:   source.created_at,
          updated_at:   source.created_at,
        }
      end

      return if notifications.empty?

      # rubocop:disable Rails/SkipsModelValidations
      Notification.insert_all!(notifications)
      User.where(id: notifications.pluck(:recipient_id)).touch_all(:notifications_updated_at)
      # rubocop:enable Rails/SkipsModelValidations
    end

    def denotify(source, target)
      return nil if source.nil? || target.nil?

      subs = Subscription.where(answer: target)
      Notification.where(target:, recipient: subs.map(&:user)).delete_all
    end

    def for(source, target)
      muted_by = Relationships::Mute.where(target: source.user).pluck(&:source_id)

      Subscription.where(answer: target)
                  .where.not(user: source.user)
                  .where.not(user_id: muted_by)
    end
  end
end
