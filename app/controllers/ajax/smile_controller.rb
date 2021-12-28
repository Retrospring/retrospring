class Ajax::SmileController < AjaxController
  def create
    params.require :id

    answer = Answer.find(params[:id])

    begin
      current_user.smile answer
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :fail
      @response[:message] = I18n.t('messages.smile.create.fail')
      return
    end

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.smile.create.okay')
    @response[:success] = true
  end

  def destroy
    params.require :id

    answer = Answer.find(params[:id])

    begin
      current_user.unsmile answer
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :fail
      @response[:message] = I18n.t('messages.smile.destroy.fail')
      return
    end

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.smile.destroy.okay')
    @response[:success] = true
  end

  def create_comment
    params.require :id

    comment = Comment.find(params[:id])

    begin
      current_user.smile_comment comment
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :fail
      @response[:message] = I18n.t('messages.smile.create_comment.fail')
      return
    end

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.smile.create_comment.okay')
    @response[:success] = true
  end

  def destroy_comment
    params.require :id

    comment = Comment.find(params[:id])

    begin
      current_user.unsmile_comment comment
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :fail
      @response[:message] = I18n.t('messages.smile.destroy_comment.fail')
      return
    end

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.smile.destroy_comment.okay')
    @response[:success] = true
  end
end
