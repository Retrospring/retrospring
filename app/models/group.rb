class Group < ActiveRecord::Base
  belongs_to :user
  has_many :group_members, dependent: :destroy

  before_validation do
    self.name = self.display_name.downcase.sub(/\s+/, '-')
  end

  def add_member(user)
    GroupMember.create! group: self, user: user
  end
end
