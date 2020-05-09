# frozen_string_literal: true

class StaticController < ApplicationController
  def index
    if user_signed_in?
      @timeline = current_user.cursored_timeline(last_id: params[:last_id])
      @timeline_last_id = @timeline.map(&:id).min
      @more_data_available = !current_user.cursored_timeline(last_id: @timeline_last_id, size: 1).count.zero?

      respond_to do |format|
        format.html
        format.js { render layout: false }
      end
    else
      return render 'static/front'
    end
  end

  def about

  end

  def faq

  end

  def privacy_policy

  end

  def terms

  end
end
