class AnswerController < ApplicationController
  def show
    @answer = Answer.find(params[:id])
    @display_all = true
  end
end
