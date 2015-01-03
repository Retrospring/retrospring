class Inbox < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

  def answer(answer_content, user)
    answer = user.answer(self.question, answer_content)
    self.destroy
    answer
  end

  def remove
    self.question.destroy if self.question.can_be_removed?
    self.destroy
  end
end
