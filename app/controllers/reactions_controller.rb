# frozen_string_literal: true

class ReactionsController < ApplicationController
  def index
    answer = Answer.includes([smiles: { user: :profile }]).find(params[:id])

    render "index", locals: { a: answer }
  end
end
