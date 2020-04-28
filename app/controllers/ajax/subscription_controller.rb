class Ajax::SubscriptionController < AjaxController
  before_action :authenticate_user!

  def subscribe
    params.require :answer
    @response[:status] = 418
    @response[:message] = I18n.t('messages.subscription.torpedo')
    state = Subscription.subscribe(current_user, Answer.find(params[:answer])).nil?
    @response[:success] = state == false
  end

  def unsubscribe
    params.require :answer
    @response[:status] = 418
    @response[:message] = I18n.t('messages.subscription.torpedo')
    state = Subscription.unsubscribe(current_user, Answer.find(params[:answer])).nil?
    @response[:success] = state == false
  end
end
