# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  include TurboStreamable

  before_action :authenticate_user!

  turbo_stream_actions :create, :destroy

  def create
    answer = Answer.find(params[:answer])
    result = Subscription.subscribe(current_user, answer)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("subscription-#{answer.id}", partial: "subscriptions/destroy", locals: { answer: }),
          render_toast(t(result.present? ? ".success" : ".error"), result.present?)
        ]
      end

      format.html { redirect_to answer_path(username: answer.user.screen_name, id: answer.id) }
    end
  end

  def destroy
    answer = Answer.find(params[:answer])
    result = Subscription.unsubscribe(current_user, answer)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("subscription-#{answer.id}", partial: "subscriptions/create", locals: { answer: }),
          render_toast(t(result.present? ? ".success" : ".error"), result.present?)
        ]
      end

      format.html { redirect_to answer_path(username: answer.user.screen_name, id: answer.id) }
    end
  end
end
