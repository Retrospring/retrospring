class Ajax::ListController < AjaxController
  def create
    @response[:status] = :err

    unless user_signed_in?
      @response[:status] = :noauth
      @response[:message] = I18n.t('messages.noauth')
      return
    end

    begin
      params.require :name
    rescue ActionController::ParameterMissing => e
      Sentry.capture_exception(e)
      @response[:status] = :toolong
      @response[:message] = I18n.t('messages.list.create.noname')
      return
    end
    params.require :user

    begin
      target_user = User.find_by_screen_name!(params[:user])
      list = List.create! user: current_user, display_name: params[:name]
    rescue ActiveRecord::RecordInvalid => e
      Sentry.capture_exception(e)
      @response[:status] = :toolong
      @response[:message] = I18n.t('messages.list.create.toolong')
      return
    rescue ActiveRecord::RecordNotFound => e
      Sentry.capture_exception(e)
      @response[:status] = :notfound
      @response[:message] = I18n.t('messages.list.create.notfound')
      return
    rescue ActiveRecord::RecordNotUnique => e
      Sentry.capture_exception(e)
      @response[:status] = :exists
      @response[:message] = I18n.t('messages.list.create.exists')
      return
    end

    @response[:status] = :okay
    @response[:success] = true
    @response[:message] = I18n.t('messages.list.create.okay')
    @response[:render] = render_to_string(partial: 'modal/list/item', locals: { list: list, user: target_user })
  end

  def destroy
    @response[:status] = :err

    unless user_signed_in?
      @response[:status] = :noauth
      @response[:message] = I18n.t('messages.noauth')
      return
    end

    params.require :list

    begin
      List.where(user: current_user, name: params[:list]).first.destroy!
    rescue ActiveRecord::RecordNotFound => e
      Sentry.capture_exception(e)
      @response[:status] = :notfound
      @response[:message] = I18n.t('messages.list.destroy.notfound')
      return
    end

    @response[:status] = :okay
    @response[:success] = true
    @response[:message] = I18n.t('messages.list.destroy.okay')
  end

  def membership
    @response[:status] = :err

    unless user_signed_in?
      @response[:status] = :noauth
      @response[:message] = I18n.t('messages.noauth')
      return
    end

    params.require :user
    params.require :list
    params.require :add

    add = params[:add] == 'true'

    begin
      list = current_user.lists.find_by_name!(params[:list])
    rescue ActiveRecord::RecordNotFound => e
      Sentry.capture_exception(e)
      @response[:status] = :notfound
      @response[:message] = I18n.t('messages.list.membership.notfound')
      return
    end

    target_user = User.find_by_screen_name!(params[:user])

    if add
      list.add_member target_user if list.members.find_by_user_id(target_user.id).nil?
      @response[:checked] = true
      @response[:message] = I18n.t('messages.list.membership.add')
    else
      list.remove_member target_user unless list.members.find_by_user_id(target_user.id).nil?
      @response[:checked] = false
      @response[:message] = I18n.t('messages.list.membership.remove')
    end

    @response[:status] = :okay
    @response[:success] = true
  end
end
