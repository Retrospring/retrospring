class GroupController < ApplicationController
  before_filter :authenticate_user!

  def index
    @group = current_user.groups.find_by_name!(params[:group_name])
    @timeline = @group.timeline.paginate(page: params[:page])
  end
end
