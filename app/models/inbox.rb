class Inbox < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

  def answer(answer, user)
    answer = Answer.create!(content: answer,
                            user: user,
                            question: self.question)
    user.increment! :answered_count
    self.question.increment! :answer_count
    self.destroy
    answer
  end

  def remove
    self.question.destroy if self.question.can_be_removed
    self.destroy
  end
end
