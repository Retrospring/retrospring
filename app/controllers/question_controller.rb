class QuestionController < ApplicationController
  def show
    @question = Question.find(params[:id])
    @answers = @question.cursored_answers(last_id: params[:last_id])
    @answers_last_id = @answers.map(&:id).min
    @more_data_available = !@question.cursored_answers(last_id: @answers_last_id, size: 1).count.zero?

    respond_to do |format|
      format.html
      format.turbo_stream { render layout: false, status: :see_other }
    end
  end
end
