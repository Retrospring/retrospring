class GroupMember < ActiveRecord::Base
  has_one :user
  has_one :group
end
