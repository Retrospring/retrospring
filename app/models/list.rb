# frozen_string_literal: true

class List < ApplicationRecord
  include List::TimelineMethods

  belongs_to :user
  has_many :list_members, dependent: :destroy

  validates :name, length: { minimum: 1 }
  validates :display_name, length: { maximum: 30 }

  before_validation do
    self.display_name.strip!
    self.name = self.display_name.parameterize
    self.name = '-followers-' if self.name == 'followers'
  end

  alias members list_members

  def add_member(user)
    ListMember.create! list: self, user: user
  end

  def remove_member(user)
    ListMember.where(list: self, user: user).first!.destroy
  end
end
