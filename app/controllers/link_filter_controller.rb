# frozen_string_literal: true

class LinkFilterController < ApplicationController
  def index
    redirect_to root_path unless params[:url]

    @link = params[:url]
  end
end
