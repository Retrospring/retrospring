class Ajax::SmileController < ApplicationController
  def create
    params.require :id

    answer = Answer.find(params[:id])

    begin
      current_user.smile answer
    rescue
      @status = :fail
      @message = "You have already smiled that answer."
      @success = false
      return
    end

    @status = :okay
    @message = "Successfully smiled answer."
    @success = true
  end

  def destroy
    params.require :id

    answer = Answer.find(params[:id])

    begin
      current_user.unsmile answer
    rescue
      @status = :fail
      @message = "You have not smiled that answer."
      @success = false
      return
    end

    @status = :okay
    @message = "Successfully unsmiled answer."
    @success = true
  end
end
