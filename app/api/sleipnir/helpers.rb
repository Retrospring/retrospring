module Sleipnir::Helpers
  include Sleipnir::Helpers::User

  def privileged? (user = nil)
    if current_user.nil?
      return false
    end

    unless user.nil?
      if current_user == user
        return true
      end
    end

    if current_user.mod?
      if current_scopes.has_scopes?(['moderation'])
        return true
      end
    end

    return false
  end
end
