class SearchController < ApplicationController
  def index
    @results = []
    @query = params[:q]
    return if @query.blank?

    @results = if params[:multi_search] == "1"
                 multi_search_experiment
               else
                 [*Answer.search(@query), *Question.search(@query)]
               end
  end

  private

  def multi_search_experiment
    MeiliSearch::Rails.client.multi_search(
      [Answer, Question].map do |klass|
        {
          q:                  @query,
          index_uid:          klass.name.to_s,
          show_ranking_score: true,
        }
      end
    )["results"].flat_map do |h|
      model = h["indexUid"].constantize # bad practice!
      results = model.find(h["hits"].pluck("id")).map { |r| [r.id.to_s, r] }.to_h
      h["hits"].map { |hit| [hit["_rankingScore"], results[hit["id"]]] }
    end
      .sort_by(&:first)
      .reverse
      .tap { |results| Rails.logger.debug(results) }
      .map(&:last)
  end
end
