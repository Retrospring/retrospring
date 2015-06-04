class Question < ActiveRecord::Base
  belongs_to :user
  has_many :answers, dependent: :destroy
  has_many :inboxes, dependent: :destroy
  belongs_to :application, class_name: "Doorkeeper::Application"

  validates :content, length: { maximum: 255 }

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
