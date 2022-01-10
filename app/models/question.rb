class Question < ApplicationRecord
  include Question::AnswerMethods

  belongs_to :user, optional: true
  has_many :answers, dependent: :destroy
  has_many :inboxes, dependent: :destroy

  validates :content, length: { maximum: 512 }

  before_destroy do
    rep = Report.where(target_id: self.id, type: 'Reports::Question')
    rep.each do |r|
      unless r.nil?
        r.deleted = true
        r.save
      end
    end

    user.decrement! :asked_count unless self.author_is_anonymous
  end

  def can_be_removed?
    return false if self.answers.count > 0
    return false if Inbox.where(question: self).count > 1
    true
  end
end
