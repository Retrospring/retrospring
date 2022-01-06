class Report < ApplicationRecord
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

  class << self
    include CursorPaginatable

    define_cursor_paginator :cursored_reports, :list_reports
    define_cursor_paginator :cursored_reports_of_type, :list_reports_of_type

    def list_reports(options = {})
      self.where(options.merge!(deleted: false)).reverse_order
    end

    def list_reports_of_type(type, options = {})
      self.where(options.merge!(deleted: false)).where('LOWER(type) = ?', "reports::#{type}").reverse_order
    end
  end
end
