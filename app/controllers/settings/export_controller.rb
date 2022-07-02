# frozen_string_literal: true

class Settings::ExportController < ApplicationController
  before_action :authenticate_user!

  def index
    if current_user.export_processing
      flash[:info] = t(".info")
    end
  end

  def create
    if current_user.can_export?
      ExportWorker.perform_async(current_user.id)
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end

    redirect_to settings_export_path
  end
end
