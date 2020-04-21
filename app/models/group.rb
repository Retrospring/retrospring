# frozen_string_literal: true

class Group < ApplicationRecord
  include Group::TimelineMethods

  belongs_to :user
  has_many :group_members, dependent: :destroy

  validates :name, length: { minimum: 1 }
  validates :display_name, length: { maximum: 30 }

  before_validation do
    self.display_name.strip!
    self.name = self.display_name.parameterize
    self.name = '-followers-' if self.name == 'followers'
  end

  alias members group_members

  def add_member(user)
    GroupMember.create! group: self, user: user
  end

  def remove_member(user)
    GroupMember.where(group: self, user: user).first!.destroy
  end
end
