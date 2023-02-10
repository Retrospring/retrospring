# frozen_string_literal: true

class AnswerPolicy
  attr_reader :user, :answer

  def initialize(user, answer)
    @user = user
    @answer = answer
  end

  def pin? = answer.user == user

  def unpin? = answer.user == user
end
