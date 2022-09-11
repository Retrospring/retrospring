# frozen_string_literal: true

class Ajax::WebPushController < AjaxController
  def key
    certificate = Rpush::Webpush::App.find_by(name: "webpush").certificate

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
end
