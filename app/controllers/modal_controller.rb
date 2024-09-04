# frozen_string_literal: true

class ModalController < ApplicationController
  include ActionView::Helpers::TagHelper
  include Turbo::FramesHelper

  def close
    return redirect_to root_path unless turbo_frame_request?

    render inline: turbo_frame_tag("modal") # rubocop:disable Rails/RenderInline
  end
end
