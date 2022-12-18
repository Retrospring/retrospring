# frozen_string_literal: true

module ApplicationHelper
  include ApplicationHelper::GraphMethods
  include ApplicationHelper::TitleMethods

  def inbox_count
    return 0 unless user_signed_in?

    count = Inbox.select("COUNT(id) AS count")
                 .where(new: true)
                 .where(user_id: current_user.id)
                 .group(:user_id)
                 .order(:count)
                 .first
    return nil if count.nil?
    return nil unless count.count.positive?

    count.count
  end

  def notification_count
    return 0 unless user_signed_in?

    count = Notification.for(current_user).where(new: true).count
    return nil unless count.positive?

    count
  end

  def privileged?(user)
    !current_user.nil? && ((current_user == user) || current_user.mod?)
  end

  def rails_admin_path_for_resource(resource)
    [rails_admin_path, resource.model_name.param_key, resource.id].join("/")
  end
end
