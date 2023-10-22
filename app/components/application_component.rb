# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  include ApplicationHelper
  delegate :current_user, to: :helpers
  delegate :user_signed_in?, to: :helpers
end
