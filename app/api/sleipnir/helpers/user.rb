module Sleipnir::Helpers::User
  def globalize_paperclip(entity)
    if entity[0] == "/"
      # so dirty
      "http#{APP_CONFIG["https"] && "s" || ""}://#{APP_CONFIG["hostname"]}#{APP_CONFIG["port"] && APP_CONFIG["port"] != 80 && ":#{APP_CONFIG["port"]}" || ""}#{entity}"
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
end
