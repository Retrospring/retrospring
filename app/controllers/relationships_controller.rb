# frozen_string_literal: true

class RelationshipsController < ApplicationController
  include TurboStreamable

  turbo_stream_actions :create, :destroy

  before_action :authenticate_user!
  before_action :not_readonly!

  def create
    params.require :screen_name

    UseCase::Relationship::Create.call(
      source_user: current_user,
      target_user: ::User.find_by!(screen_name: params[:screen_name]),
      type:        params[:type],
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("#{params[:type]}-#{params[:screen_name]}", partial: "relationships/destroy", locals: { type: params[:type], screen_name: params[:screen_name] }),
          render_toast(t(".#{params[:type]}.success"))
        ]
      end

      format.html { redirect_back(fallback_location: user_path(username: params[:screen_name])) }
    end
  end

  def destroy
    UseCase::Relationship::Destroy.call(
      source_user: current_user,
      target_user: ::User.find_by!(screen_name: params[:screen_name]),
      type:        params[:type],
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("#{params[:type]}-#{params[:screen_name]}", partial: "relationships/create", locals: { type: params[:type], screen_name: params[:screen_name] }),
          render_toast(t(".#{params[:type]}.success"))
        ]
      end

      format.html { redirect_back(fallback_location: user_path(username: params[:screen_name])) }
    end
  end
end
