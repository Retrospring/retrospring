class GroupController < ApplicationController
  before_filter :index

  def index
    @timeline = Group.find_by_name(params[:group_name]).timeline.paginate(page: params[:page])
  end
end