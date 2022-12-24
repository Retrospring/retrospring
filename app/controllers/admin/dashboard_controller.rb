# frozen_string_literal: true

require "sidekiq/api"

class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @sidekiq = {
      processes: Sidekiq::ProcessSet.new,
      stats:     Sidekiq::Stats.new
    }
  end
end
