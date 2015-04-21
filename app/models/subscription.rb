class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :answer

  class << self
    def subscribe(recipient, target)
      if Subscription.find_by(user: recipient, answer: target).nil?
        Subscription.new(user: recipient, answer: target).save!
      end
    end

    def unsubscribe(recipient, target)
      if recipient.nil? or target.nil?
        return nil
      end

      subs = Subscription.find_by(user: recipient, answer: target)
      subs.destroy unless subs.nil?
    end

    def destruct(target)
      if target.nil?
        return nil
      end
      Subscription.where(answer: target).destroy_all
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
