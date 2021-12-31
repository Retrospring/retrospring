class AnswerController < ApplicationController
  def show
    @answer = Answer.includes(comments: [:user, :smiles], question: [:user], smiles: [:user]).find(params[:id])
    @display_all = true

    if user_signed_in?
      notif = Notification.where(target_type: "Answer", target_id: @answer.id, recipient_id: current_user.id, new: true).first
      unless notif.nil?
        notif.new = false
        notif.save
      end
      notif = Notification.where(target_type: "Comment", target_id: @answer.comments.pluck(:id), recipient_id: current_user.id, new: true)
      notif.update_all(new: false) unless notif.empty?
      notif = Notification.where(target_type: "Smile", target_id: @answer.smiles.pluck(:id), recipient_id: current_user.id, new: true)
      notif.update_all(new: false) unless notif.empty?
      # @answer.comments.smiles throws
      notif = Notification.where(target_type: "CommentSmile", target_id: @answer.comment_smiles.pluck(:id), recipient_id: current_user.id, new: true)
      notif.update_all(new: false) unless notif.empty?
    end
  end
end
