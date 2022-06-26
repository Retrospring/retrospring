# frozen_string_literal: true

module User::BanMethods
  def permanently_banned?
    bans.current.first&.permanent? || false
  end

  def banned?
    bans.current.count.positive?
  end

  def unban
    bans.current.update(
      # -1s to account for flakyness with timings in tests
      expires_at: DateTime.now.utc - 1.second
    )
  end

  # Bans a user.
  # @param expiry [DateTime, nil] the expiry time of the ban
  # @param reason [String, nil] Reason for the ban. This is displayed to the user.
  # @param banned_by [User] User who instated the ban
  def ban(expiry = nil, reason = nil, banned_by = nil)
    ::UserBan.create!(
      user:       self,
      expires_at: expiry,
      banned_by:  banned_by,
      reason:     reason
    )
  end
end
