# frozen_string_literal: true

class CommentController < ApplicationController
  def index
    answer = Answer.find(params[:id])
    @comments = Comment.where(answer:).includes([{ user: :profile }, :smiles])

    render "index", locals: { a: answer }
  end

  def show_reactions
    comment = Comment.find(params[:id])
    @reactions = Appendable::Reaction.where(parent_type: "Comment", parent: comment.id).includes([{ user: :profile }])

    redirect_to answer_path(username: comment.answer.user.screen_name, id: comment.answer.id) unless turbo_frame_request?
  end
end
