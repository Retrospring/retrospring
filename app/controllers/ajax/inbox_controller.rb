# frozen_string_literal: true

class Ajax::InboxController < AjaxController
  def remove
    params.require :id

    inbox = InboxEntry.find(params[:id])

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
      InboxEntry.where(user: current_user).find_each(&:remove)
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
      @target_user = User.where("LOWER(screen_name) = ?", params[:author].downcase).first!
      @inbox = current_user.inbox_entries.joins(:question)
                           .where(questions: { user_id: @target_user.id, author_is_anonymous: false })
      @inbox.each(&:remove)
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
