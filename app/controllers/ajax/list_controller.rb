# frozen_string_literal: true

class Ajax::ListController < AjaxController
  before_action :authenticate_user!
  before_action :not_readonly!, except: %i[destroy]

  def create
    params.require :name
    params.require :user

    @response[:status] = :err

    target_user = User.find_by!(screen_name: params[:user])
    list = List.create! user: current_user, display_name: params[:name]

    @response[:status] = :okay
    @response[:success] = true
    @response[:message] = t(".success")
    @response[:render] = render_to_string(partial: "modal/list/item", locals: { list: list, user: target_user })
  end

  def destroy
    params.require :list

    @response[:status] = :err

    List.where(user: current_user, name: params[:list]).first.destroy!

    @response[:status] = :okay
    @response[:success] = true
    @response[:message] = t(".success")
  end

  def membership
    params.require :user
    params.require :list
    params.require :add

    @response[:status] = :err

    add = params[:add] == "true"

    target_user = User.find_by!(screen_name: params[:user])
    list = current_user.lists.find_by!(name: params[:list])

    raise Errors::ListingSelfBlockedOther if current_user.blocking?(target_user)
    raise Errors::ListingOtherBlockedSelf if target_user.blocking?(current_user)

    if add
      list.add_member target_user if list.members.find_by(user_id: target_user.id).nil?
      @response[:checked] = true
      @response[:message] = t(".success.add")
    else
      list.remove_member target_user unless list.members.find_by(user_id: target_user.id).nil?
      @response[:checked] = false
      @response[:message] = t(".success.remove")
    end

    @response[:status] = :okay
    @response[:success] = true
  end
end
