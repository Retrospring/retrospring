class Ajax::SmileController < AjaxController
  def create
    params.require :id

    answer = Answer.find(params[:id])

    begin
      current_user.smile answer
    rescue Errors::Base => e
      @response[:status] = e.code
      @response[:message] = I18n.t(e.locale_tag)
      return
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :fail
      @response[:message] = t(".error")
      return
    end

    @response[:status] = :okay
    @response[:message] = t(".success")
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
      @response[:message] = t(".error")
      return
    end

    @response[:status] = :okay
    @response[:message] = t(".success")
    @response[:success] = true
  end

  def create_comment
    params.require :id

    comment = Comment.find(params[:id])

    begin
      current_user.smile comment
    rescue Errors::Base => e
      @response[:status] = e.code
      @response[:message] = I18n.t(e.locale_tag)
      return
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :fail
      @response[:message] = t(".error")
      return
    end

    @response[:status] = :okay
    @response[:message] = t(".success")
    @response[:success] = true
  end

  def destroy_comment
    params.require :id

    comment = Comment.find(params[:id])

    begin
      current_user.unsmile comment
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :fail
      @response[:message] = t(".error")
      return
    end

    @response[:status] = :okay
    @response[:message] = t(".success")
    @response[:success] = true
  end
end
