# frozen_string_literal: true

class UserController < ApplicationController
  before_action :set_user
  before_action :hidden_social_graph_redirect, only: %i[followers followings]

  def show
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
      format.turbo_stream
    end
  end

  def followers
    @title = "Followers"
    @relationships = @user.cursored_follower_relationships(last_id: params[:last_id])
    @relationships_last_id = @relationships.map(&:id).min
    @more_data_available = !@user.cursored_follower_relationships(last_id: @relationships_last_id, size: 1).count.zero?
    @users = @relationships.map(&:source)
    @type = :follower

    respond_to do |format|
      format.html { render "show_follow" }
      format.turbo_stream { render "show_follow" }
    end
  end

  def followings
    @title = "Following"
    @relationships = @user.cursored_following_relationships(last_id: params[:last_id])
    @relationships_last_id = @relationships.map(&:id).min
    @more_data_available = !@user.cursored_following_relationships(last_id: @relationships_last_id, size: 1).count.zero?
    @users = @relationships.map(&:target)
    @type = :friend

    respond_to do |format|
      format.html { render "show_follow" }
      format.turbo_stream { render "show_follow" }
    end
  end

  def questions
    @title = "Questions"
    @questions = @user.cursored_questions(author_is_anonymous: false, direct: belongs_to_current_user? || moderation_view?, last_id: params[:last_id])
    @questions_last_id = @questions.map(&:id).min
    @more_data_available = !@user.cursored_questions(author_is_anonymous: false, direct: belongs_to_current_user? || moderation_view?, last_id: @questions_last_id, size: 1).count.zero?

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def set_user
    @user = User.where("LOWER(screen_name) = ?", params[:username].downcase).includes(:profile).first!
  end

  def hidden_social_graph_redirect
    return if belongs_to_current_user? || !@user.privacy_hide_social_graph

    redirect_to user_path(@user)
  end

  def belongs_to_current_user? = @user == current_user
end
