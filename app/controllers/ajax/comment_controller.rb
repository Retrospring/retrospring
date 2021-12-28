class Ajax::CommentController < AjaxController
  def create
    params.require :answer
    params.require :comment

    answer = Answer.find(params[:answer])

    begin
      current_user.comment(answer, params[:comment])
    rescue ActiveRecord::RecordInvalid => e
      Sentry.capture_exception(e)
      @response[:status] = :rec_inv
      @response[:message] = I18n.t('messages.comment.create.rec_inv')
      return
    end

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.comment.create.okay')
    @response[:success] = true
    @response[:render] = render_to_string(partial: 'answerbox/comments', locals: { a: answer })
    @response[:count] = answer.comment_count
  end

  def destroy
    params.require :comment

    @response[:status] = :err
    comment = Comment.find(params[:comment])

    unless (current_user == comment.user) or (current_user == comment.answer.user) or (privileged? comment.user)
      @response[:status] = :nopriv
      @response[:message] = I18n.t('messages.comment.destroy.nopriv')
      return
    end

    @response[:count] = comment.answer.comment_count - 1
    comment.destroy

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.comment.destroy.okay')
    @response[:success] = true
  end
end
