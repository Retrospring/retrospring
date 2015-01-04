class QuestionController < ApplicationController
  def show
    @question = Question.find(params[:id])
    @answers = @question.answers.reverse_order.paginate(page: params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end
end
