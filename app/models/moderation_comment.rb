class ModerationComment < ActiveRecord::Base
  belongs_to :user
  belongs_to :report
  validates :user_id, presence: true
  validates :report_id, presence: true

  validates :content, length: { maximum: 160 }
end
