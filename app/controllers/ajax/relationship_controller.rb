# frozen_string_literal: true

require "use_case/relationship/create"
require "use_case/relationship/destroy"
require "errors"

class Ajax::RelationshipController < AjaxController
  before_action :authenticate_user!

  def create
    UseCase::Relationship::Create.call(
      current_user_id: current_user.id,
      target_user: params[:target_user],
      type: params[:type]
    )
    @response[:success] = true
    @response[:message] = t(".success")
  rescue Errors::Base => e
    @response[:message] = t(e.locale_tag)
  ensure
    return_response
  end

  def destroy
    UseCase::Relationship::Destroy.call(
      current_user_id: current_user.id,
      target_user: params[:target_user],
      type: params[:type]
    )
    @response[:success] = true
    @response[:message] = t(".success")
  rescue Errors::Base => e
    @response[:message] = t(e.locale_tag)
  ensure
    return_response
  end
end
