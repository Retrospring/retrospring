# frozen_string_literal: true

class Settings::ExportController < ApplicationController
  before_action :authenticate_user!
  before_action :mark_notifications_as_read, only: %i[index]

  def index
    flash[:info] = t(".info") if current_user.export_processing
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

  private

  # rubocop:disable Rails/SkipsModelValidations
  def mark_notifications_as_read
    updated = Notification::DataExported
              .where(recipient: current_user, new: true)
              .update_all(new: false)
    current_user.touch(:notifications_updated_at) if updated.positive?
  end
  # rubocop:enable Rails/SkipsModelValidations
end
