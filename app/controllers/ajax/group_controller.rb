class Ajax::GroupController < ApplicationController
  def create
    @status = :err
    @success = false

    unless user_signed_in?
      @status = :noauth
      @message = "requires authentication"
      return
    end

    begin
      params.require :name
    rescue ActionController::ParameterMissing
      @status = :toolong
      @message = "Please give that group a name."
      return
    end
    params.require :user

    begin
      target_user = User.find_by_screen_name(params[:user])
      group = Group.create! user: current_user, display_name: params[:name]
    rescue ActiveRecord::RecordInvalid
      @status = :toolong
      @message = "Group name too long (30 characters max.)"
      return
    rescue ActiveRecord::RecordNotFound
      @status = :notfound
      @message = "Could not find user."
      return
    rescue ActiveRecord::RecordNotUnique
      @status = :exists
      @message = "Group already exists."
      return
    end

    @status = :okay
    @success = true
    @message = "Successfully created group."
    @render = render_to_string(partial: 'user/modal_group_item', locals: { group: group, user: target_user })
  end

  def destroy
    @status = :err
    @success = false

    unless user_signed_in?
      @status = :noauth
      @message = "requires authentication"
      return
    end

    params.require :group

    begin
      Group.where(user: current_user, name: params[:group]).first.destroy!
    rescue ActiveRecord::RecordNotFound
      @status = :notfound
      @message = "Could not find group."
      return
    end

    @status = :okay
    @success = true
    @message = "Successfully deleted group."
  end

  def membership
    @status = :err
    @success = false

    unless user_signed_in?
      @status = :noauth
      @message = "requires authentication"
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
      @message = "Group not found."
      return
    end

    target_user = User.find_by_screen_name(params[:user])

    if add
      group.add_member target_user if group.members.find_by_user_id(target_user.id).nil?
      @checked = true
      @message = "Successfully added user to group."
    else
      group.remove_member target_user unless group.members.find_by_user_id(target_user.id).nil?
      @checked = false
      @message = "Successfully removed user from group."
    end
      
    @status = :okay
    @success = true
  end
end
