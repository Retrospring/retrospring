class GroupController < ApplicationController
  before_filter :authenticate_user!

  def index
    @timeline = current_user.groups.find_by_name!(params[:group_name]).timeline.paginate(page: params[:page])
  end
end
