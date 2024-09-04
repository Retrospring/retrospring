# frozen_string_literal: true

class Settings::ExportController < ApplicationController
  before_action :authenticate_user!

  def index
    flash[:info] = t(".info") if current_user.export_processing
  end

  def create
    redirect_to settings_export_path
  end
end
