class Profile < ApplicationRecord
  belongs_to :user

  attr_readonly :user_id

  validates :display_name, length: { maximum: 50 }
  validates :location,     length: { maximum: 72 }
  validates :description,  length: { maximum: 200 }

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
    display_name.presence || user.screen_name
  end
end
