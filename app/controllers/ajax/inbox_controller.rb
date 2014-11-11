class Ajax::InboxController < ApplicationController
  def destroy
    params.require :id
    params.require :answer

    inbox = Inbox.find(params[:id])

    unless current_user == inbox.user
      @status = :fail
      @message = "question not in your inbox"
      @success = false
      return
    end
    
    answer = Answer.create(content: params[:answer],
                           user: current_user,
                           question: inbox.question)

    unless current_user.nil?
      current_user.increment! :answered_count
    end

    Inbox.destroy inbox.id

    @status = :okay
    @message = "Successfully answered question."
    @success = true
  end
end
