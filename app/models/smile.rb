class Smile < ActiveRecord::Base
  belongs_to :user
  belongs_to :answer
  validates :user_id, presence: true
  validates :answer_id, presence: true

  def notification_type(*_args)
    Notifications::Smiled
  end
end
