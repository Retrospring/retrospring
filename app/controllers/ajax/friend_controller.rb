class Ajax::FriendController < ApplicationController
  rescue_from(ActionController::ParameterMissing) do |param_miss_ex|
    @status = :parameter_error
    @message = I18n.t('messages.parameter_error', parameter: param_miss_ex.param.capitalize)
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
      @message = I18n.t('messages.friend.create.fail')
      @success = false
      return
    end

    @status = :okay
    @message = I18n.t('messages.friend.create.okay')
    @success = true
  end

  def destroy
    params.require :screen_name

    target_user = User.find_by_screen_name(params[:screen_name])

    begin
      current_user.unfollow target_user
    rescue
      @status = :fail
      @message = I18n.t('messages.friend.destroy.fail')
      @success = false
      return
    end

    @status = :okay
    @message = I18n.t('messages.friend.destroy.okay')
    @success = true
  end
end
