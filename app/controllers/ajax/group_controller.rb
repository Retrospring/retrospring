class Ajax::GroupController < AjaxController
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
      NewRelic::Agent.notice_error(e)
      @response[:status] = :toolong
      @response[:message] = I18n.t('messages.group.create.noname')
      return
    end
    params.require :user

    begin
      target_user = User.find_by_screen_name!(params[:user])
      group = Group.create! user: current_user, display_name: params[:name]
    rescue ActiveRecord::RecordInvalid => e
      NewRelic::Agent.notice_error(e)
      @response[:status] = :toolong
      @response[:message] = I18n.t('messages.group.create.toolong')
      return
    rescue ActiveRecord::RecordNotFound => e
      NewRelic::Agent.notice_error(e)
      @response[:status] = :notfound
      @response[:message] = I18n.t('messages.group.create.notfound')
      return
    rescue ActiveRecord::RecordNotUnique => e
      NewRelic::Agent.notice_error(e)
      @response[:status] = :exists
      @response[:message] = I18n.t('messages.group.create.exists')
      return
    end

    @response[:status] = :okay
    @response[:success] = true
    @response[:message] = I18n.t('messages.group.create.okay')
    @response[:render] = render_to_string(partial: 'user/modal_group_item', locals: { group: group, user: target_user })
  end

  def destroy
    @response[:status] = :err

    unless user_signed_in?
      @response[:status] = :noauth
      @response[:message] = I18n.t('messages.noauth')
      return
    end

    params.require :group

    begin
      Group.where(user: current_user, name: params[:group]).first.destroy!
    rescue ActiveRecord::RecordNotFound => e
      NewRelic::Agent.notice_error(e)
      @response[:status] = :notfound
      @response[:message] = I18n.t('messages.group.destroy.notfound')
      return
    end

    @response[:status] = :okay
    @response[:success] = true
    @response[:message] = I18n.t('messages.group.destroy.okay')
  end

  def membership
    @response[:status] = :err

    unless user_signed_in?
      @response[:status] = :noauth
      @response[:message] = I18n.t('messages.noauth')
      return
    end

    params.require :user
    params.require :group
    params.require :add

    add = params[:add] == 'true'

    begin
      group = current_user.groups.find_by_name!(params[:group])
    rescue ActiveRecord::RecordNotFound => e
      NewRelic::Agent.notice_error(e)
      @response[:status] = :notfound
      @response[:message] = I18n.t('messages.group.membership.notfound')
      return
    end

    target_user = User.find_by_screen_name!(params[:user])

    if add
      group.add_member target_user if group.members.find_by_user_id(target_user.id).nil?
      @response[:checked] = true
      @response[:message] = I18n.t('messages.group.membership.add')
    else
      group.remove_member target_user unless group.members.find_by_user_id(target_user.id).nil?
      @response[:checked] = false
      @response[:message] = I18n.t('messages.group.membership.remove')
    end

    @response[:status] = :okay
    @response[:success] = true
  end
end
