class Announcement < ApplicationRecord
  belongs_to :user

  validates :content, presence: true
  validates :starts_at, presence: true
  validates :link_href, presence: true, if: -> { link_text.present? }
  validate :starts_at, :validate_date_range

  def self.find_active
    Rails.cache.fetch "announcement_active", expires_in: 1.minute do
      where "starts_at <= :now AND ends_at > :now", now: Time.current
    end
  end

  def active?
    Time.now.utc >= starts_at && Time.now.utc < ends_at
  end

  def link_present?
    link_text.present?
  end

  def validate_date_range
    if starts_at > ends_at
      errors.add(:starts_at, "Start date must be before end date")
    end
  end
end
