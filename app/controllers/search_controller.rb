class SearchController < ApplicationController
  def index
    @results = []
    query = params[:q]
    return if query.blank?

    @results = []
  end
end
