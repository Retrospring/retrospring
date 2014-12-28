class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
  has_many :comments, dependent: :destroy
  has_many :smiles, dependent: :destroy

  def notification_type(*_args)
    Notifications::QuestionAnswered
  end

  def remove
    self.user.decrement! :answered_count
    self.question.decrement! :answer_count
    self.smiles.each do |smile|
      Notification.denotify self.user, smile
    end
    self.comments.each do |comment|
      comment.user.decrement! :commented_count
      Notification.denotify self.user, comment
    end
    Notification.denotify self.question.user, self
    self.destroy
  end
end
