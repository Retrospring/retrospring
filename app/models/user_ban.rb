class UserBan < ApplicationRecord
  belongs_to :user
  belongs_to :banned_by, class_name: "User", optional: true

  scope :current, -> { where("expires_at IS NULL or expires_at > NOW()") }

  def permanent?
    expires_at.nil?
  end

  def current?
    permanent? || expires_at > Time.now.utc
  end
end
