class Inbox < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

  before_create do
    raise "User does not want to receive anonymous questions" if self.question.author_is_anonymous and self.question.author_name != 'justask' and !self.user.privacy_allow_anonymous_questions?
  end

  def answer(answer_content, user, via = nil)
    answer = user.answer(self.question, answer_content, via)
    self.destroy
    answer
  end

  def remove
    self.question.destroy if self.question.can_be_removed?
    self.destroy
  end
end
