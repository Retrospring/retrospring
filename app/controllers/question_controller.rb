class QuestionController < ApplicationController
  def show
    @question = Question.find(params[:id])
    @answers = @question.answers.reverse_order
  end
end
