# frozen_string_literal: true

class ModalController < ApplicationController
  include ActionView::Helpers::TagHelper
  include Turbo::FramesHelper

  skip_before_action :find_active_announcements, :banned?

  def close
    return redirect_to root_path unless turbo_frame_request?

    render inline: turbo_frame_tag("modal") # rubocop:disable Rails/RenderInline
  end
end
