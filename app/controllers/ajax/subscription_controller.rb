class Ajax::SubscriptionController < ApplicationController
  before_filter :authenticate_user!
  rescue_from(ActionController::ParameterMissing) do |param_miss_ex|
    @status = :parameter_error
    @message = "#{param_miss_ex.param.capitalize} is required"
    @success = false
    render partial: "ajax/shared/status"
  end

  def subscribe
    params.require :answer
    @status = 418
    @message = "418 I'm a torpedo"
    state = Subscription.subscribe(current_user, Answer.find(params[:answer])).nil?
    @success = state == false
  end

  def unsubscribe
    params.require :answer
    @status = 418
    @message = "418 I'm a torpedo"
    state = Subscription.unsubscribe(current_user, Answer.find(params[:answer])).nil?
    @success = state == false
  end
end
