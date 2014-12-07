class Ajax::CommentController < ApplicationController
  def create
    params.require :answer
    params.require :comment

    answer = Answer.find(params[:answer])

    begin
      current_user.comment(answer, params[:comment])
    rescue ActiveRecord::RecordInvalid
      @status = :rec_inv
      @message = "Your comment is too long."
      @success = false
      return
    end

    @status = :okay
    @message = "Comment posted successfully."
    @success = true
    @render = render_to_string(partial: 'shared/comments', locals: { a: answer })
  end
end
