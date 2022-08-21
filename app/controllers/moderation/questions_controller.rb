# frozen_string_literal: true

class Moderation::QuestionsController < ApplicationController
  before_action :authenticate_user!

  def show
    @questions = Question.where(author_identifier: params[:author_identifier])
  end
end
