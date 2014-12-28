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
    @count = answer.comment_count
  end

  def destroy
    params.require :comment

    @status = :err
    @success = false
    comment = Comment.find(params[:comment])

    unless (current_user == comment.user) or (current_user == comment.answer.user) or (privileged? comment.user)
      @status = :nopriv
      @message = "can't delete other people's comments"
      @success = false
      return
    end

    @count = comment.answer.comment_count - 1
    comment.destroy

    @status = :okay
    @message = "Successfully deleted comment."
    @success = true
  end
end
