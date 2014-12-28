class Report < ActiveRecord::Base
  belongs_to :user
  has_many :moderation_votes, dependent: :destroy
  has_many :moderation_comments, dependent: :destroy
  validates :type, presence: true
  validates :target_id, presence: true
  validates :user_id, presence: true

  def target
    type.sub('Reports::', '').constantize.where(id: target_id).first
  end

  def votes
    moderation_votes.where(upvote: true).count - moderation_votes.where(upvote: false).count
  end
end
