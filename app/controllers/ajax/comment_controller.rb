class Ajax::CommentController < ApplicationController
  rescue_from(ActionController::ParameterMissing) do |param_miss_ex|
    @status = :parameter_error
    @message = I18n.t('messages.parameter_error', parameter: param_miss_ex.param.capitalize)
    @success = false
    render partial: "ajax/shared/status"
  end

  def create
    params.require :answer
    params.require :comment

    answer = Answer.find(params[:answer])

    begin
      current_user.comment(answer, params[:comment])
    rescue ActiveRecord::RecordInvalid
      @status = :rec_inv
      @message = I18n.t('messages.comment.create.rec_inv')
      @success = false
      return
    end

    @status = :okay
    @message = I18n.t('messages.comment.create.okay')
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
      @message = I18n.t('messages.comment.destroy.nopriv')
      @success = false
      return
    end

    @count = comment.answer.comment_count - 1
    comment.destroy

    @status = :okay
    @message = I18n.t('messages.comment.destroy.okay')
    @success = true
  end
end
