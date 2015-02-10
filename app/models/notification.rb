class Notification < ActiveRecord::Base
  belongs_to :recipient, class_name: 'User'
  belongs_to :target, polymorphic: true

  class << self
    def for(recipient, options={})
      self.where(options.merge!(recipient: recipient)).order(:created_at).reverse_order
    end

    def notify(recipient, target)
      return nil unless target.respond_to? :notification_type

      notif_type = target.notification_type
      return nil unless notif_type

      make_notification(recipient, target, notif_type)
    end

    def denotify(recipient, target)
      return nil unless target.respond_to? :notification_type

      notif_type = target.notification_type
      return nil unless notif_type

      notif = notif_type.find_by(recipient: recipient, target: target)
      notif.destroy unless notif.nil?
    end

    private

      def make_notification(recipient, target, notification_type)
        n = notification_type.new(target: target,
                                  recipient: recipient,
                                  new: true)
        n.save!
        n
      end
  end
end
