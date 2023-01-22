class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :answer
  validates :user_id, presence: true
  validates :answer_id, presence: true
  has_many :smiles, class_name: "Appendable::Reaction", foreign_key: :parent_id, dependent: :destroy

  validates :content, length: { maximum: 512 }

  # rubocop:disable Rails/SkipsModelValidations
  after_create do
    Subscription.subscribe self.user, answer, false
    Subscription.notify self, answer
    user.increment! :commented_count
    answer.increment! :comment_count
  end

  before_destroy do
    rep = Report.where(target_id: self.id, type: 'Reports::Comment')
    rep.each do |r|
      unless r.nil?
        r.deleted = true
        r.save
      end
    end

    Subscription.denotify self, answer
    user&.decrement! :commented_count
    answer&.decrement! :comment_count
  end
  # rubocop:enable Rails/SkipsModelValidations

  def notification_type(*_args)
    Notification::Commented
  end
end
