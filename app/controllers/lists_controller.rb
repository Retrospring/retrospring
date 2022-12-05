# frozen_string_literal: true

class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[index]

  def index
    @lists = List.where(user: current_user)
  end

  def create
    target_user = User.find_by!(screen_name: params[:user])
    list = List.create! user: current_user, display_name: params[:name]

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("create-form", partial: "lists/form", locals: { user: target_user }),
          turbo_stream.prepend("lists", partial: "lists/item", locals: { list:, user: target_user })
        ]
      end

      format.html { redirect_to user_path(target_user) }
    end
  end

  def update
    @add = params[:add] == "true"

    @target_user = User.find_by!(screen_name: params[:user])
    @list = current_user.lists.find(params[:list])

    raise Errors::ListingSelfBlockedOther if current_user.blocking?(@target_user)
    raise Errors::ListingOtherBlockedSelf if @target_user.blocking?(@current_user)

    if @add
      @list.add_member @target_user if @list.members.find_by(user_id: @target_user.id).nil?
    else
      @list.remove_member @target_user unless @list.members.find_by(user_id: @target_user.id).nil?
    end

    respond_to do |format|
      format.turbo_stream do
        render "update", layout: false, status: :see_other
      end

      format.html { redirect_to user_path(@target_user) }
    end
  end

  def destroy
    @list = List.find(params[:list])

    @list.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("list_#{params[:list]}")
      end

      format.html { redirect_to root_path }
    end
  end

  private

  def set_user
    @user = User.where("LOWER(screen_name) = ?", params[:user].downcase).includes(:profile).first!
  end

  def list_params
    params.require(:list).permit(:name)
  end
end
