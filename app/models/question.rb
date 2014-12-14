class Question < ActiveRecord::Base
  belongs_to :user
  has_many :answers

  validates :content, length: { maximum: 255 }

  def can_be_removed?
    return false if self.answers.count > 0
    return false if Inbox.where(question: self).count > 1
    self.user.decrement! :asked_count
    true
  end
end
