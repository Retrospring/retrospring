class Profile < ApplicationRecord
  belongs_to :user

  attr_readonly :user_id

  validates :display_name, length: { maximum: 32 }
  validates :location,     length: { maximum: 72 }
  validates :description,  length: { maximum: 256 }

  before_save do
    unless website.blank?
      self.website = if website.match %r{\Ahttps?://}
                       website
                     else
                       "http://#{website}"
                     end
    end
  end

  def display_website
    website.match(/https?:\/\/([A-Za-z.\-0-9]+)\/?(?:.*)/i)[1]
  rescue NoMethodError
    website
  end

  def safe_name
    self.display_name.presence || self.screen_name
  end
end
