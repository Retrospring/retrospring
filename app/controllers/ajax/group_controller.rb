class Ajax::GroupController < ApplicationController
  rescue_from(ActionController::ParameterMissing) do |param_miss_ex|
    @status = :parameter_error
    @message = I18n.t('messages.parameter_error', parameter: param_miss_ex.param.capitalize)
    @success = false
    render partial: "ajax/shared/status"
  end
  
  def create
    @status = :err
    @success = false

    unless user_signed_in?
      @status = :noauth
      @message = I18n.t('messages.noauth')
      return
    end

    begin
      params.require :name
    rescue ActionController::ParameterMissing
      @status = :toolong
      @message = I18n.t('messages.group.create.noname')
      return
    end
    params.require :user

    begin
      target_user = User.find_by_screen_name(params[:user])
      group = Group.create! user: current_user, display_name: params[:name]
    rescue ActiveRecord::RecordInvalid
      @status = :toolong
      @message = I18n.t('messages.group.create.toolong')
      return
    rescue ActiveRecord::RecordNotFound
      @status = :notfound
      @message = I18n.t('messages.group.create.notfound')
      return
    rescue ActiveRecord::RecordNotUnique
      @status = :exists
      @message = I18n.t('messages.group.create.exists')
      return
    end

    @status = :okay
    @success = true
    @message = I18n.t('messages.group.create.okay')
    @render = render_to_string(partial: 'user/modal_group_item', locals: { group: group, user: target_user })
  end

  def destroy
    @status = :err
    @success = false

    unless user_signed_in?
      @status = :noauth
      @message = I18n.t('messages.noauth')
      return
    end

    params.require :group

    begin
      Group.where(user: current_user, name: params[:group]).first.destroy!
    rescue ActiveRecord::RecordNotFound
      @status = :notfound
      @message = I18n.t('messages.group.destroy.notfound')
      return
    end

    @status = :okay
    @success = true
    @message = I18n.t('messages.group.destroy.okay')
  end

  def membership
    @status = :err
    @success = false

    unless user_signed_in?
      @status = :noauth
      @message = I18n.t('messages.noauth')
      return
    end

    params.require :user
    params.require :group
    params.require :add

    add = params[:add] == 'true'

    begin
      group = current_user.groups.find_by_name(params[:group])
    rescue ActiveRecord::RecordNotFound
      @status = :notfound
      @message = I18n.t('messages.group.membership.notfound')
      return
    end

    target_user = User.find_by_screen_name(params[:user])

    if add
      group.add_member target_user if group.members.find_by_user_id(target_user.id).nil?
      @checked = true
      @message = I18n.t('messages.group.membership.add')
    else
      group.remove_member target_user unless group.members.find_by_user_id(target_user.id).nil?
      @checked = false
      @message = I18n.t('messages.group.membership.remove')
    end

    @status = :okay
    @success = true
  end
end
