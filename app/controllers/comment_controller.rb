# frozen_string_literal: true

class CommentController < ApplicationController
  def index
    answer = Answer.find(params[:id])
    @comments = Comment.where(answer:).includes([{ user: :profile }, :smiles])

    render "index", locals: { a: answer }
  end
end
