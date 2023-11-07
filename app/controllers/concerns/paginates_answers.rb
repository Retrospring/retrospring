# frozen_string_literal: true

module PaginatesAnswers
  def paginate_answers
    @answers = yield(last_id: params[:last_id])
    answer_ids = @answers.map(&:id)
    @answers_last_id = answer_ids.min
    answer_ids += @pinned_answers.pluck(:id) if @pinned_answers.present?
    @more_data_available = !yield(last_id: @answers_last_id, size: 1).count.zero?

    return unless user_signed_in?

    @reacted_answer_ids = Reaction.where(user: current_user, parent_type: "Answer", parent_id: answer_ids).pluck(:parent_id)
    @subscribed_answer_ids = Subscription.where(user: current_user, answer_id: answer_ids).pluck(:answer_id)
  end
end
