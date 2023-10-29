# frozen_string_literal: true

class Comments::ReactionsController < ApplicationController
  def index
    comment = Comment.find(params[:id])
    @reactions = Reaction.where(parent_type: "Comment", parent: comment.id).includes([{ user: :profile }])

    redirect_to answer_path(username: comment.answer.user.screen_name, id: comment.answer.id) unless turbo_frame_request?
  end
end
