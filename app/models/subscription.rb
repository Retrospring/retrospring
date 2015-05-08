class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :answer

  class << self
    def for(target)
      Subscription.where(answer: target)
    end

    def is_subscribed(recipient, target)
      existing = Subscription.find_by(user: recipient, answer: target)
      if existing.nil?
        false
      else
        existing.is_active
      end
    end

    def subscribe(recipient, target, force = true)
      existing = Subscription.find_by(user: recipient, answer: target)
      if existing.nil?
        Subscription.new(user: recipient, answer: target).save!
      elsif force
        existing.update(is_active: true)
      end
    end

    def unsubscribe(recipient, target)
      if recipient.nil? or target.nil?
        return nil
      end

      subs = Subscription.find_by(user: recipient, answer: target)
      subs.update(is_active: false) unless subs.nil?
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

      Subscription.where(answer: target, is_active: true).each do |subs|
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
