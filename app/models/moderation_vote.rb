class ModerationVote < ActiveRecord::Base
  belongs_to :user
  belongs_to :report
  validates :user_id, presence: true
  validates :report_id, presence: true
end
