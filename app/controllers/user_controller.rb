class UserController < ApplicationController
  def show
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).includes(:profile).first!
    @answers = @user.cursored_answers(last_id: params[:last_id])
    @answers_last_id = @answers.map(&:id).min
    @more_data_available = !@user.cursored_answers(last_id: @answers_last_id, size: 1).count.zero?

    if user_signed_in?
      notif = Notification.where(target_type: "Relationship", target_id: @user.active_follow_relationships.where(target_id: current_user.id).pluck(:id), recipient_id: current_user.id, new: true).first
      unless notif.nil?
        notif.new = false
        notif.save
      end
    end

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def followers
    @title = 'Followers'
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).includes(:profile).first!
    @relationships = @user.cursored_follower_relationships(last_id: params[:last_id])
    @relationships_last_id = @relationships.map(&:id).min
    @more_data_available = !@user.cursored_follower_relationships(last_id: @relationships_last_id, size: 1).count.zero?
    @users = @relationships.map(&:source)
    @type = :friend

    respond_to do |format|
      format.html { render "show_follow" }
      format.js { render "show_follow", layout: false }
    end
  end

  # rubocop:disable Metrics/AbcSize
  def followings
    @title = 'Following'
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).includes(:profile).first!
    @relationships = @user.cursored_following_relationships(last_id: params[:last_id])
    @relationships_last_id = @relationships.map(&:id).min
    @more_data_available = !@user.cursored_following_relationships(last_id: @relationships_last_id, size: 1).count.zero?
    @users = @relationships.map(&:target)
    @type = :friend

    respond_to do |format|
      format.html { render "show_follow" }
      format.js { render "show_follow", layout: false }
    end
  end
  # rubocop:enable Metrics/AbcSize

  def questions
    @title = 'Questions'
    @user = User.where('LOWER(screen_name) = ?', params[:username].downcase).includes(:profile).first!
    @questions = @user.cursored_questions(author_is_anonymous: false, last_id: params[:last_id])
    @questions_last_id = @questions.map(&:id).min
    @more_data_available = !@user.cursored_questions(author_is_anonymous: false, last_id: @questions_last_id, size: 1).count.zero?

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end
end
