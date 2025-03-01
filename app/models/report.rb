class Report < ApplicationRecord
  belongs_to :user
  belongs_to :target_user, class_name: "User", optional: true
  validates :type, presence: true
  validates :target_id, presence: true
  validates :user_id, presence: true

  def target
    type.sub('Reports::', '').constantize.where(id: target_id).first
  end
end
