# frozen_string_literal: true

class AboutController < ApplicationController
  def index
    return unless Retrospring::Config.advanced_frontpage_enabled?

    render template: "about/index_advanced"
  end

  def about; end

  def privacy_policy; end

  def terms; end
end
