class Inbox < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

  def answer(answer, user)
    Answer.create(content: answer,
                  user: user,
                  question: self.question)
    user.increment! :answered_count
    self.question.increment! :answer_count
    self.destroy
  end

  def remove
    self.question.decrement! :answer_count
    unless self.question.user.nil?
      self.question.user.decrement! :asked_count if self.question.answer_count == 1
    end

    self.question.destroy if self.question.answer_count == 1
    self.destroy
  end
end
