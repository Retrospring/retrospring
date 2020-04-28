class Ajax::FriendController < AjaxController
  def create
    params.require :screen_name

    target_user = User.find_by_screen_name(params[:screen_name])

    begin
      current_user.follow target_user
    rescue => e
      NewRelic::Agent.notice_error(e)
      @response[:status] = :fail
      @response[:message] = I18n.t('messages.friend.create.fail')
      return
    end

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.friend.create.okay')
    @response[:success] = true
  end

  def destroy
    params.require :screen_name

    target_user = User.find_by_screen_name(params[:screen_name])

    begin
      current_user.unfollow target_user
    rescue => e
      NewRelic::Agent.notice_error(e)
      @response[:status] = :fail
      @response[:message] = I18n.t('messages.friend.destroy.fail')
      return
    end

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.friend.destroy.okay')
    @response[:success] = true
  end
end
