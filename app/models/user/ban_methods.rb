# frozen_string_literal: true

module User::BanMethods
  def permanently_banned?
    bans.current.first&.permanent? || false
  end

  def banned?
    Rails.cache.fetch("#{cache_key}/banned") do
      bans.current.count.positive?
    end
  end

  def unban
    bans.current.update(
      # -1s to account for flakyness with timings in tests
      expires_at: DateTime.now.utc - 1.second,
    )
    Rails.cache.delete("#{cache_key}/banned")
  end

  # Bans a user.
  # @param expiry [DateTime, nil] the expiry time of the ban
  # @param reason [String, nil] Reason for the ban. This is displayed to the user.
  # @param banned_by [User] User who instated the ban
  def ban(expiry = nil, reason = nil, banned_by = nil)
    ::UserBan.create!(
      user:       self,
      expires_at: expiry,
      banned_by:,
      reason:,
    )
    Rails.cache.delete("#{cache_key}/banned")
  end
end
