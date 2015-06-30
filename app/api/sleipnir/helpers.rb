module Sleipnir::Helpers
  include Sleipnir::Helpers::User

  def privileged? (user)
    false if current_user.nil?
    true if current_user == user
    true if current_user.mod? and not current_scopes.index('moderation').nil?
    false
  end

  def new_inbox_count
    return 0 if current_user.nil?
    current_user.inbox.find_by(new: true).count
  end

  def new_notification_count
    return 0 if current_user.nil?
    current_user.notifications.find_by(new: true).count
  end
end
