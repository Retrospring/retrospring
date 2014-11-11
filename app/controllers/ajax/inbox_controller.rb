class Ajax::InboxController < ApplicationController
  def destroy
    params.require :id
    params.require :answer

    question = Question.create!(content: params[:question],
                                author_is_anonymous: params[:anonymousQuestion],
                                user: current_user)

    unless current_user.nil?
      current_user.increment! :answered_count
    end

    inbox = Inbox.find(params[:id]).first

    unless current_user.id == Inbox.user_id
      @status = :fail
      @message = "question not in your inbox"
      @success = false
      return
    end
    
    answer = Answer.create(content: params[:answer],
                           user: current_user,
                           question: inbox.question)

    Inbox.destroy inbox.id

    @status = :okay
    @message = "Successfully answered question."
    @success = true
  end
end
