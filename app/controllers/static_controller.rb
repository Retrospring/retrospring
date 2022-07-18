# frozen_string_literal: true

class StaticController < ApplicationController
  def linkfilter
    redirect_to root_path unless params[:url]
    
    @link = params[:url]
  end
end
