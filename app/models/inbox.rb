class Inbox < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

  def answer(answer, user)
    Answer.create(content: answer,
                  user: user,
                  question: self.question)
    user.increment! :answered_count
    self.destroy
  end

  def remove
    unless self.question.user.nil?
      self.question.user.decrement! :asked_count
    end

    self.question.destroy
    self.destroy
  end
end
