# frozen_string_literal: true

class ReactionsController < ApplicationController
  include TurboStreamable

  before_action :authenticate_user!, only: %w[create destroy]

  turbo_stream_actions :create, :destroy

  def index
    answer = Answer.includes([smiles: { user: :profile }]).find(params[:id])

    render "index", locals: { a: answer }
  end

  def create
    params.require :id

    target = target_class.find(params[:id])

    UseCase::Reaction::Create.call(
      source_user: current_user,
      target:,
    )

    target.reload

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("reaction-#{params[:type]}-#{params[:id]}", partial: "reactions/destroy", locals: { type: params[:type], target: }),
          render_toast(t(".#{params[:type].downcase}.success"))
        ]
      end

      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def destroy
    params.require :id

    target = target_class.find(params[:id])

    UseCase::Reaction::Destroy.call(
      source_user: current_user,
      target:,
    )

    target.reload

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("reaction-#{params[:type]}-#{params[:id]}", partial: "reactions/create", locals: { type: params[:type], target: }),
          render_toast(t(".#{params[:type].downcase}.success"))
        ]
      end

      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  private

  ALLOWED_TYPES = %w[Answer Comment].freeze
  private_constant :ALLOWED_TYPES

  def target_class
    params.require :type
    raise NameError unless ALLOWED_TYPES.include?(params[:type])

    params[:type].constantize
  end
end
