# frozen_string_literal: true

class Settings::DataController < ApplicationController
  before_action :authenticate_user!

  def index; end
end
