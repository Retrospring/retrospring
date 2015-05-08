class Ajax::SmileController < ApplicationController
  rescue_from(ActionController::ParameterMissing) do |param_miss_ex|
    @status = :parameter_error
    @message = "#{param_miss_ex.param.capitalize} is required"
    @success = false
    render partial: "ajax/shared/status"
  end
  
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

  def create_comment
    params.require :id

    comment = Comment.find(params[:id])

    begin
      current_user.smile_comment comment
    rescue
      @status = :fail
      @message = "You have already smiled that comment."
      @success = false
      return
    end

    @status = :okay
    @message = "Successfully smiled comment."
    @success = true
  end

  def destroy_comment
    params.require :id

    comment = Comment.find(params[:id])

    begin
      current_user.unsmile_comment comment
    rescue
      @status = :fail
      @message = "You have not smiled that comment."
      @success = false
      return
    end

    @status = :okay
    @message = "Successfully unsmiled comment."
    @success = true
  end
end
