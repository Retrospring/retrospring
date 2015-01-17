class Ajax::GroupController < ApplicationController
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

    group = nil

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
