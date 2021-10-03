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
    @users = User
      .where('confirmed_at IS NOT NULL')
      .where(permanently_banned: false)
      .where(banned_until: nil)
      .where('answered_count > 0')
      .where('asked_count > 0')
      .count

    @questions = Question.count
    @answers = Answer.count
    @comments = Comment.count
    @smiles = Smile.count + CommentSmile.count
  end

  def faq

  end

  def privacy_policy

  end

  def terms

  end
end
