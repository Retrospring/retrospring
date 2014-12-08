class Question < ActiveRecord::Base
  belongs_to :user
  has_many :answers

  validates :content, length: { maximum: 255 }
end
