class UserBan < ApplicationRecord
  belongs_to :user
  belongs_to :banned_by, class_name: 'User'
end
