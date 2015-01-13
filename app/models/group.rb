class Group < ActiveRecord::Base
  belongs_to :user
  has_many :group_members, dependent: :destroy

  before_validation do
    self.name = self.display_name.downcase.sub(/\s+/, '-')
    self.name = 'group-followers' if self.name == 'followers'
  end

  alias members group_members

  def add_member(user)
    GroupMember.create! group: self, user: user
  end

  def remove_member(user)
    GroupMember.where(group: self, user: user).first!.destroy
  end

  # @return [Array] the groups' timeline
  def timeline
    Answer.where("user_id in (?)", members.pluck(:user_id)).order(:created_at).reverse_order
  end
end
