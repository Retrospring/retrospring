# frozen_string_literal: true

class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!

  def index; end
end
