# frozen_string_literal: true

class Ajax::WebPushController < AjaxController
  before_action :authenticate_user!

  def key
    certificate = Rpush::Webpush::App.find_by(name: "webpush").certificate

    @response[:status] = :okay
    @response[:success] = true
    @response[:key] = JSON.parse(certificate)["public_key"]
  end

  def check
    params.require(:endpoint)

    found = current_user.web_push_subscriptions.where("subscription ->> 'endpoint' = ?", params[:endpoint]).first

    @response[:status] = if found
                           if found.failures >= 3
                             :failed
                           else
                             :subscribed
                           end
                         else
                           :unsubscribed
                         end
    @response[:success] = true
  end

  def subscribe
    params.require(:subscription)

    WebPushSubscription.create!(
      user:         current_user,
      subscription: params[:subscription]
    )

    @response[:status] = :okay
    @response[:success] = true
    @response[:message] = t(".subscription_count", count: current_user.web_push_subscriptions.count)
  end

  def unsubscribe # rubocop:disable Metrics/AbcSize
    params.require(:endpoint)

    removed = if params.key?(:endpoint)
                current_user.web_push_subscriptions.where("subscription ->> 'endpoint' = ?", params[:endpoint]).destroy_all
              else
                current_user.web_push_subscriptions.destroy_all
              end

    count = current_user.web_push_subscriptions.count

    @response[:status] = removed.any? ? :okay : :err
    @response[:success] = removed.any?
    @response[:message] = t(".subscription_count", count:)
    @response[:count] = count
  end
end
