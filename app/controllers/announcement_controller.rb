class AnnouncementController < ApplicationController
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
      flash[:success] = "Announcement created successfully."
      redirect_to action: :index
    else
      render 'announcement/new'
    end
  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

  def update
  end

  def destroy
    if Announcement.destroy(params[:id])
      flash[:success] = "Announcement deleted successfully."
    else
      flash[:error] = "Failed to delete announcement."
    end
    redirect_to announcement_index_path
  end

  private

  def announcement_params
    params.require(:announcement).permit(:content, :link_text, :link_href, :starts_at, :ends_at)
  end
end
