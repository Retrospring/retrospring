class UserBan < ApplicationRecord
  belongs_to :user
  belongs_to :banned_by, class_name: 'User'

  scope :current, -> { where('expires_at IS NULL or expires_at < NOW()') }
end
