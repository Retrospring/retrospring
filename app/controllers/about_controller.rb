# frozen_string_literal: true

class AboutController < ApplicationController
  def index
    return redirect_to(edit_user_registration_path) if user_signed_in?
    return unless Retrospring::Config.advanced_frontpage_enabled?

    render template: "about/index_advanced"
  end

  def about; end

  def privacy_policy; end

  def terms; end
end
