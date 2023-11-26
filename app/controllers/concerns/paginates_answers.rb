# frozen_string_literal: true

module PaginatesAnswers
  def paginate_answers
    @answers = yield(last_id: params[:last_id])
    answer_ids = @answers.map(&:id)
    @answers_last_id = answer_ids.min
    @more_data_available = !yield(last_id: @answers_last_id, size: 1).select("answers.id").count.zero?
  end
end
