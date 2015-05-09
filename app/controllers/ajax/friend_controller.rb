class Ajax::FriendController < ApplicationController
  rescue_from(ActionController::ParameterMissing) do |param_miss_ex|
    @status = :parameter_error
    @message = "#{param_miss_ex.param.capitalize} is required"
    @success = false
    render partial: "ajax/shared/status"
  end
  
  def create
    params.require :screen_name

    target_user = User.find_by_screen_name(params[:screen_name])

    begin
      current_user.follow target_user
    rescue
      @status = :fail
      @message = "You are already following that user."
      @success = false
      return
    end

    @status = :okay
    @message = "Successfully followed user."
    @success = true
  end

  def destroy
    params.require :screen_name

    target_user = User.find_by_screen_name(params[:screen_name])

    begin
      current_user.unfollow target_user
    rescue
      @status = :fail
      @message = "You are not following that user."
      @success = false
      return
    end

    @status = :okay
    @message = "Successfully unfollowed user."
    @success = true
  end
end
