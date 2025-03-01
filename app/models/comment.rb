class Comment < ApplicationRecord
  belongs_to :user, counter_cache: :commented_count
  belongs_to :answer, counter_cache: :comment_count
  validates :user_id, presence: true
  validates :answer_id, presence: true
  has_many :smiles, class_name: "Reaction", foreign_key: :parent_id, dependent: :destroy

  validates :content, length: { maximum: 512 }

  after_create do
    Subscription.subscribe user, answer
    Subscription.notify self, answer
  end

  before_destroy do
    rep = Report.where(target_id: self.id, type: 'Reports::Comment')
    rep.each do |r|
      unless r.nil?
        r.resolved = true
        r.save
      end
    end

    Subscription.denotify self, answer
  end

  def notification_type(*_args)
    Notification::Commented
  end
end
