# frozen_string_literal: true

class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[index]

  def index
    @lists = List.where(user: current_user)
  end

  def destroy
    @list = List.find(params[:id])

    @list.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("list_#{params[:id]}")
      end
    end
  end

  private

  def set_user
    @user = User.where("LOWER(screen_name) = ?", params[:username].downcase).includes(:profile).first!
  end

  def list_params
    params.require(:list).permit(:name)
  end
end
