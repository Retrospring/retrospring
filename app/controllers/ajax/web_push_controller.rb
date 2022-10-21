# frozen_string_literal: true

class Ajax::WebPushController < AjaxController
  def key
    certificate = Rpush::Webpush::App.find_by(name: "webpush").certificate

    @response[:status] = :okay
    @response[:success] = true
    @response[:key] = JSON.parse(certificate)["public_key"]
  end

  def subscribe
    WebPushSubscription.create!(
      user:         current_user,
      subscription: params[:subscription]
    )

    @response[:status] = :okay
    @response[:success] = true
  end

  def unsubscribe
    params.permit(:endpoint)

    if params.key?(:endpoint)
      current_user.web_push_subscriptions.where("subscription ->> 'endpoint' = ?", params[:endpoint]).destroy
    else
      current_user.web_push_subscriptions.destroy_all
    end

    @response[:status] = :okay
    @response[:success] = true
  end
end
