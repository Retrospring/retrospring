# frozen_string_literal: true

class Settings::MutesController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = current_user.muted_users
    @rules = MuteRule.where(user: current_user)
  end

  def create
    result = UseCase::MuteRule::Create.call(user: current_user, phrase: params[:muted_phrase])

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("form", partial: "settings/mutes/form"),
          turbo_stream.append("rules", partial: "settings/mutes/rule", locals: { rule: result[:resource] })
        ]
      end

      format.html { redirect_to settings_muted_path }
    end
  end

  def destroy
    rule = MuteRule.find(params[:id])

    authorize rule

    UseCase::MuteRule::Destroy.call(rule:)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("rule_#{params[:id]}")
      end

      format.html { redirect_to settings_muted_path }
    end
  end
end
