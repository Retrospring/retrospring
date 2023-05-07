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
      @response[:message] = t(".invalid")
      return
    end

    comments = Comment.where(answer:).includes([{ user: :profile }, :smiles])

    @response[:status] = :okay
    @response[:message] = t(".success")
    @response[:success] = true
    @response[:render] = render_to_string(partial: "answerbox/comments", locals: { a: answer, comments: })
    @response[:count] = answer.comment_count
  end

  def destroy
    params.require :comment

    @response[:status] = :err
    comment = Comment.find(params[:comment])

    unless (current_user == comment.user) or (current_user == comment.answer.user) or (privileged? comment.user)
      @response[:status] = :nopriv
      @response[:message] = t(".nopriv")
      return
    end

    @response[:count] = comment.answer.comment_count - 1
    comment.destroy

    @response[:status] = :okay
    @response[:message] = t(".success")
    @response[:success] = true
  end
end
