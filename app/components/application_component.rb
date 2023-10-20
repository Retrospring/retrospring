# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  include ApplicationHelper

  def current_user = helpers.current_user

  def user_signed_in? = helpers.user_signed_in?

end
