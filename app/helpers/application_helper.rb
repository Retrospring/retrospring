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

    count = Notification.for(current_user).where(new: true)
    return nil if count.nil?
    return nil unless count.count.positive?

    count.count
  end

  def privileged?(user)
    !current_user.nil? && ((current_user == user) || current_user.mod?)
  end

  def ios_web_app?
    user_agent = request.env["HTTP_USER_AGENT"] || "Mozilla/5.0"
    # normal MobileSafari.app UA: Mozilla/5.0 (iPhone; CPU iPhone OS 8_1_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B435 Safari/600.1.4
    # webapp UA: Mozilla/5.0 (iPhone; CPU iPhone OS 8_1_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12B435
    return true if user_agent.match(/^Mozilla\/\d+\.\d+ \(i(?:Phone|Pad|Pod); CPU(?:.*) like Mac OS X\)(?:.*) Mobile(?:\S*)$/)

    false
  end

  def rails_admin_path_for_resource(resource)
    [rails_admin_path, resource.model_name.param_key, resource.id].join("/")
  end
end
