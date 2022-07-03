# frozen_string_literal: true

class Settings::MutesController < ApplicationController
  before_action :authenticate_user!

  def index
    @rules = MuteRule.where(user: current_user)
  end
end
