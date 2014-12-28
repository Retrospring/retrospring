class Ajax::AnswerController < ApplicationController
  def destroy
    params.require :answer

    answer = Answer.find(params[:answer])

    unless (current_user == answer.user) or (privileged? answer.user)
      @status = :nopriv
      @message = "can't delete other people's answers"
      @success = false
      return
    end

    if answer.user == current_user
      Inbox.create!(user: answer.user, question: answer.question, new: true)
    end # TODO: decide what happens with the question
    answer.remove

    @status = :okay
    @message = "Successfully deleted answer."
    @success = true
  end
end
