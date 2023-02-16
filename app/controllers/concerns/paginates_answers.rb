# frozen_string_literal: true

module PaginatesAnswers
  def paginate_answers
    answer_ids = @answers.map(&:id)
    answer_ids += @pinned_answers.pluck(:id) if @pinned_answers.present?
    @answers_last_id = answer_ids.min
    @more_data_available = !@user.cursored_answers(last_id: @answers_last_id, size: 1).count.zero?
    Subscription.where(user: current_user, answer_id: answer_ids + @pinned_answers.pluck(:id)).pluck(:answer_id) if user_signed_in?
  end
end
