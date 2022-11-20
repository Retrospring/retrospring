# frozen_string_literal: true

class Admin::AnnouncementController < ApplicationController
  before_action :authenticate_user!

  def index
    @announcements = Announcement.all
  end

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.user = current_user
    if @announcement.save
      flash[:success] = t(".success")
      redirect_to action: :index
    else
      flash[:error] = t(".error")
      render "admin/announcement/new"
    end
  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

  def update
    @announcement = Announcement.find(params[:id])
    @announcement.update(announcement_params)
    if @announcement.save
      flash[:success] = t(".success")
      redirect_to announcement_index_path
    else
      flash[:error] = t(".error")
      render "admin/announcement/edit"
    end
  end

  def destroy
    if Announcement.destroy(params[:id])
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end
    redirect_to announcement_index_path
  end

  private

  def announcement_params
    params.require(:announcement).permit(:content, :link_text, :link_href, :starts_at, :ends_at)
  end
end
