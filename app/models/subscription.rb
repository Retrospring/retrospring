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
      if recipient.nil? or target.nil?
        return nil
      end

      subs = Subscription.find_by(user: recipient, answer: target)
      subs&.destroy
    end

    def destruct(target)
      if target.nil?
        return nil
      end
      Subscription.where(answer: target).destroy_all
    end

    def destruct_by(recipient, target)
      if recipient.nil? or target.nil?
        return nil
      end

      subs = Subscription.find_by(user: recipient, answer: target)
      subs.destroy unless subs.nil?
    end

    def notify(source, target)
      if source.nil? or target.nil?
        return nil
      end

      Subscription.where(answer: target).each do |subs|
        next unless not subs.user == source.user
        Notification.notify subs.user, source
      end
    end

    def denotify(source, target)
      if source.nil? or target.nil?
        return nil
      end
      Subscription.where(answer: target).each do |subs|
        Notification.denotify subs.user, source
      end
    end
  end
end
