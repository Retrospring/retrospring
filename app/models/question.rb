class Question < ActiveRecord::Base
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :inboxes, dependent: :destroy

  validates :content, length: { maximum: 255 }

  before_create do
    raise "User does not want to receive anonymous questions" if self.author_is_anonymous and !self.user.privacy_allow_anonymous_questions?
  end

  before_destroy do
    user.decrement! :asked_count unless self.author_is_anonymous
  end

  def can_be_removed?
    return false if self.answers.count > 0
    return false if Inbox.where(question: self).count > 1
    true
  end
end
