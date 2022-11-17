class Ajax::InboxController < AjaxController
  def remove
    params.require :id

    inbox = Inbox.find(params[:id])

    unless current_user == inbox.user
      @response[:status] = :fail
      @response[:message] = t(".error")
      return
    end

    begin
      inbox.remove
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :err
      @response[:message] = t("errors.base")
      return
    end

    @response[:status] = :okay
    @response[:message] = t(".success")
    @response[:success] = true
  end

  def remove_all
    raise unless user_signed_in?

    begin
      Inbox.where(user: current_user).each { |i| i.remove }
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :err
      @response[:message] = t("errors.base")
      return
    end

    @response[:status] = :okay
    @response[:message] = t(".success")
    @response[:success] = true
  end

  def remove_all_author
    begin
      @target_user = User.where('LOWER(screen_name) = ?', params[:author].downcase).first!
      @inbox = current_user.inboxes.joins(:question)
                                   .where(questions: { user_id: @target_user.id, author_is_anonymous: false })
      @inbox.each { |i| i.remove }
    rescue => e
      Sentry.capture_exception(e)
      @response[:status] = :err
      @response[:message] = t("errors.base")
      return
    end

    @response[:status] = :okay
    @response[:message] = t(".success")
    @response[:success] = true
  end
end
