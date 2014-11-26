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
    Inbox.create!(user: answer.user, question: answer.question, new: true)
    answer.destroy

    @status = :okay
    @message = "Successfully deleted answer."
    @success = true
  end

  private

  # TODO:
  def privileged?
    if current_user && current_user.admin?
      true
    else
      false
    end
  end
end
