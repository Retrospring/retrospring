class Ajax::SubscriptionController < ApplicationController
  before_filter :authenticate_user!
  rescue_from(ActionController::ParameterMissing) do |param_miss_ex|
    @status = :parameter_error
    @message = I18n.t('messages.parameter_error', parameter: param_miss_ex.param.capitalize)
    @success = false
    render partial: "ajax/shared/status"
  end

  def subscribe
    params.require :answer
    @status = 418
    @message = I18n.t('messages.subscription.torpedo')
    state = Subscription.subscribe(current_user, Answer.find(params[:answer])).nil?
    @success = state == false
  end

  def unsubscribe
    params.require :answer
    @status = 418
    @message = I18n.t('messages.subscription.torpedo')
    state = Subscription.unsubscribe(current_user, Answer.find(params[:answer])).nil?
    @success = state == false
  end
end
