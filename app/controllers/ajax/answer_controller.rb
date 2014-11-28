class Ajax::AnswerController < ApplicationController
  def destroy
    params.require :answer

    unless current_user.nil?
      current_user.increment! :asked_count unless params[:anonymousQuestion] == 'true'
    end

    answer = Answer.find(params[:answer])
    
    unless answer.user == current_user || privileged?
      @status = :nopriv
      @message = "check yuor privlegs"
      @success = false
      return
    end

    answer.user.decrement! :answered_count
    if answer.user == current_user
      Inbox.create!(user: answer.user, question: answer.question, new: true)
    end # TODO: decide what happens with the question
    answer.destroy

    @status = :okay
    @message = "Successfully deleted answer."
    @success = true
  end
end
