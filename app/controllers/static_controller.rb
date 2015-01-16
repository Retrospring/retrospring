class StaticController < ApplicationController
  def index
    if user_signed_in?
      @timeline = current_user.timeline.paginate(page: params[:page])
      respond_to do |format|
        format.html
        format.js
      end
    end
  end

  def about
    @admins = User.where(admin: true).order(:id)
  end

  def faq

  end

  def privacy_policy

  end

  def terms

  end
end
