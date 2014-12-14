class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
  has_many :comments, dependent: :destroy
  has_many :smiles, dependent: :destroy

  def notification_type(*_args)
    Notifications::QuestionAnswered
  end
end
