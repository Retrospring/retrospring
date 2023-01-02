class Report < ApplicationRecord
  belongs_to :user
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
