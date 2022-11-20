# frozen_string_literal: true

class Settings::MutesController < ApplicationController
  before_action :authenticate_user!

  def index
    @rules = MuteRule.where(user: current_user)
  end

  def create
    rule = MuteRule.create!(user: current_user, muted_phrase: params[:muted_phrase])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("form", partial: "settings/mutes/form"),
          turbo_stream.append("rules", partial: "settings/mutes/rule", locals: { rule: })
        ]
      end

      format.html { redirect_to settings_muted_path }
    end
  end

  def destroy
    rule = MuteRule.find(params[:id])

    authorize rule

    rule.destroy!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("rule_#{params[:id]}")
      end

      format.html { redirect_to settings_muted_path }
    end
  end
end
