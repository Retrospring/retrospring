# frozen_string_literal: true

require "use_case/relationship/create"
require "use_case/relationship/destroy"
require "errors"

class Ajax::RelationshipController < AjaxController
  before_action :authenticate_user!

  def create
    params.require :screen_name

    UseCase::Relationship::Create.call(
      current_user: current_user.screen_name,
      target_user:  params[:screen_name],
      type:         params[:type]
    )
    @response[:success] = true
    @response[:message] = t("messages.friend.create.okay")
  rescue Errors::Base => e
    @response[:message] = t(e.locale_tag)
  ensure
    return_response
  end

  def destroy
    UseCase::Relationship::Destroy.call(
      current_user: current_user.screen_name,
      target_user:  params[:screen_name],
      type:         params[:type]
    )
    @response[:success] = true
    @response[:message] = t("messages.friend.destroy.okay")
  rescue Errors::Base => e
    @response[:message] = t(e.locale_tag)
  ensure
    return_response
  end
end
