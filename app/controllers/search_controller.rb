class SearchController < ApplicationController
  def index
    @results = []
    query = params[:q]
    return if query.blank?

    @results = PgSearch.multisearch(query).limit(10)
  end
end
