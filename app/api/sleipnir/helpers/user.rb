module Sleipnir::Helpers::User
  def globalize_paperclip(entity)
    if entity[0] == "/"
      "#{request.base_url}#{entity}"
    else
      entity
    end
  end

  def user_avatar_for_id(id, size = :large)
    user = User.find(id)
    if user.nil?
      nil
    else
      globalize_paperclip user.profile_picture.url(size)
    end
  end

  def user_header_for_id(id, size = :web)
    user = User.find(id)
    if user.nil?
      nil
    else
      globalize_paperclip user.profile_header.url(size)
    end
  end
  
  def new_inbox_count
    return 0 if current_user.nil?
    current_user.inboxes.where(new: true).count
  end

  def new_notification_count
    return 0 if current_user.nil?
    current_user.notifications.where(new: true).count
  end
end
