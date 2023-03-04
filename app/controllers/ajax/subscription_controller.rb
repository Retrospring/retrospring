class Ajax::SubscriptionController < AjaxController
  before_action :authenticate_user!

  def subscribe
    params.require :answer
    @response[:status] = :okay
    result = Subscription.subscribe(current_user, Answer.find(params[:answer]))
    @response[:success] = result.present?
  end

  def unsubscribe
    params.require :answer
    @response[:status] = :okay
    result = Subscription.unsubscribe(current_user, Answer.find(params[:answer]))
    @response[:success] = result&.destroyed? || false
  end
end
