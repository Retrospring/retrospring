# frozen_string_literal: true

class AnswerController < ApplicationController
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
end
