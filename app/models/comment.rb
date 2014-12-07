class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :answer
  validates :user_id, presence: true
  validates :answer_id, presence: true

  validates :content, length: { maximum: 160 }
end
