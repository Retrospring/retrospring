# frozen_string_literal: true

class AnonymousBlockController < ApplicationController
  before_action :authenticate_user!

  def create
    params.require :question

    question = Question.find(params[:question])
    authorize AnonymousBlock, :create_global? if params[:global]

    AnonymousBlock.create!(
      user:       params[:global] ? nil : current_user,
      identifier: question.author_identifier,
      question:,
      target_user: question.user
    )

    inbox_id = question.inboxes.first.id
    question.inboxes.first&.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("inbox_#{inbox_id}")
      end

      format.html { redirect_back(fallback_location: inbox_path) }
    end
  end

  def destroy
    params.require :id

    block = AnonymousBlock.find(params[:id])
    authorize block

    block.destroy!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("block_#{params[:id]}")
      end

      format.html { redirect_back(fallback_location: settings_blocks_path) }
    end
  end
end
