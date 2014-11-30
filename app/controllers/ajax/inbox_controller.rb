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

    begin
      inbox.answer params[:answer], current_user
    rescue
      @status = :err
      @message = "An error occurred"
      @success = false
      return
    end

    @status = :okay
    @message = "Successfully answered question."
    @success = true
  end

  def remove
    params.require :id

    inbox = Inbox.find(params[:id])

    unless current_user == inbox.user
      @status = :fail
      @message = "question not in your inbox"
      @success = false
      return
    end

    begin
      inbox.remove
    rescue
      @status = :err
      @message = "An error occurred"
      @success = false
      return
    end

    @status = :okay
    @message = "Successfully deleted question."
    @success = true
  end
end
