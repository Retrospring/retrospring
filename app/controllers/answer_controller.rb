# frozen_string_literal: true

class AnswerController < ApplicationController
  before_action :authenticate_user!, only: %i[pin unpin]

  include TurboStreamable

  turbo_stream_actions :pin, :unpin

  def show
    @answer = Answer.for_user(current_user).includes(question: [:user], smiles: [:user]).find(params[:id])
    @display_all = true

    return unless user_signed_in?

    mark_notifications_as_read
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

  private

  def mark_notifications_as_read
    updated = Notification.where(recipient_id: current_user.id, new: true)
                .and(Notification.where(type: "Notification::QuestionAnswered", target_id: @answer.id)
                .or(Notification.where(type: "Notification::Commented", target_id: @answer.comments.pluck(:id)))
                .or(Notification.where(type: "Notification::Smiled", target_id: @answer.smiles.pluck(:id)))
                .or(Notification.where(type: "Notification::CommentSmiled", target_id: @answer.comment_smiles.pluck(:id))))
                .update_all(new: false) # rubocop:disable Rails/SkipsModelValidations
    current_user.touch(:notifications_updated_at) if updated.positive?
  end
end
