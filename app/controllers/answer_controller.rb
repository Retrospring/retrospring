# frozen_string_literal: true

class AnswerController < ApplicationController
  before_action :authenticate_user!, only: %i[pin unpin]

  include TurboStreamable

  turbo_stream_actions :pin, :unpin

  def show
    @answer = Answer.includes(comments: %i[user smiles], question: [:user], smiles: [:user]).find(params[:id])
    @display_all = true

    if user_signed_in?
      notif = Notification.where(type: "Notification::QuestionAnswered", target_id: @answer.id, recipient_id: current_user.id, new: true).first
      notif&.update(new: false)
      notif = Notification.where(type: "Notification::Commented", target_id: @answer.comments.pluck(:id), recipient_id: current_user.id, new: true)
      notif.update_all(new: false) unless notif.empty?
      notif = Notification.where(type: "Notification::Smiled", target_id: @answer.smiles.pluck(:id), recipient_id: current_user.id, new: true)
      notif.update_all(new: false) unless notif.empty?
      notif = Notification.where(type: "Notification::CommentSmiled", target_id: @answer.comment_smiles.pluck(:id), recipient_id: current_user.id, new: true)
      notif.update_all(new: false) unless notif.empty?
    end
  end

  def pin
    answer = Answer.includes(:user).find(params[:id])
    UseCase::Answer::Pin.call(user: current_user, answer:)

    respond_to do |format|
      format.html { redirect_to(user_path(username: current_user.screen_name)) }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("ab-pin-#{answer.id}", partial: "actions/pin", locals: { answer: }),
          render_toast(t(".success"))
        ]
      end
    end
  end

  def unpin
    answer = Answer.includes(:user).find(params[:id])
    UseCase::Answer::Unpin.call(user: current_user, answer:)

    respond_to do |format|
      format.html { redirect_to(user_path(username: current_user.screen_name)) }
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update("ab-pin-#{answer.id}", partial: "actions/pin", locals: { answer: }),
          render_toast(t(".success"))
        ]
      end
    end
  end
end
