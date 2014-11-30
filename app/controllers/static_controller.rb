class StaticController < ApplicationController
  def index
  end

  def about
    @admins = User.where(admin: true).order(:id)
  end
end
