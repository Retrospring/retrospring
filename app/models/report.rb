class Report < ApplicationRecord
  belongs_to :user
  belongs_to :target_user, class_name: "User", optional: true
  validates :type, presence: true
  validates :target_id, presence: true
  validates :user_id, presence: true

  def target
    type.sub('Reports::', '').constantize.where(id: target_id).first
  end

  def append_reason(new_reason)
    if reason.nil?
      update(reason: new_reason)
    else
      update(reason: [reason || "", new_reason].join("\n"))
    end
  end
end
