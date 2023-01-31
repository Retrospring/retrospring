# frozen_string_literal: true

class UserController < ApplicationController
  before_action :set_user
  before_action :hidden_social_graph_redirect, only: %i[followers followings]
  after_action :mark_notification_as_read, only: %i[show]

  def show
    @answers = @user.cursored_answers(last_id: params[:last_id])
    @answers_last_id = @answers.map(&:id).min
    @more_data_available = !@user.cursored_answers(last_id: @answers_last_id, size: 1).count.zero?

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def followers
    @relationships = @user.cursored_follower_relationships(last_id: params[:last_id])
    @relationships_last_id = @relationships.map(&:id).min
    @more_data_available = !@user.cursored_follower_relationships(last_id: @relationships_last_id, size: 1).count.zero?
    @users = @relationships.map(&:source)
    own_followings = find_own_relationships(current_user&.active_follow_relationships)
    own_blocks = find_own_relationships(current_user&.active_block_relationships)

    respond_to do |format|
      format.html { render "show_follow", locals: { type: :follower, own_followings:, own_blocks: } }
      format.turbo_stream { render "show_follow", locals: { type: :follower, own_followings:, own_blocks: } }
    end
  end

  def followings
    @relationships = @user.cursored_following_relationships(last_id: params[:last_id])
    @relationships_last_id = @relationships.map(&:id).min
    @more_data_available = !@user.cursored_following_relationships(last_id: @relationships_last_id, size: 1).count.zero?
    @users = @relationships.map(&:target)
    own_followings = find_own_relationships(current_user&.active_follow_relationships)
    own_blocks = find_own_relationships(current_user&.active_block_relationships)

    respond_to do |format|
      format.html { render "show_follow", locals: { type: :friend, own_followings:, own_blocks: } }
      format.turbo_stream { render "show_follow", locals: { type: :friend, own_followings:, own_blocks: } }
    end
  end

  def questions
    @questions = @user.cursored_questions(author_is_anonymous: false, direct: direct_param, last_id: params[:last_id])
    @questions_last_id = @questions.map(&:id).min
    @more_data_available = !@user.cursored_questions(author_is_anonymous: false, direct: direct_param, last_id: @questions_last_id, size: 1).count.zero?

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  private

  def mark_notification_as_read
    return unless user_signed_in?

    Notification
      .where(
        target_type:  "Relationship",
        target_id:    @user.active_follow_relationships.where(target_id: current_user.id).pluck(:id),
        recipient_id: current_user.id,
        new:          true
      ).update(new: false)
  end

  def set_user
    @user = User.where("LOWER(screen_name) = ?", params[:username].downcase).includes(:profile).first!
  end

  def find_own_relationships(relationships)
    return nil if relationships.nil?

    relationships.where(target_id: @users.map(&:id))&.select(:target_id)&.map(&:target_id)
  end

  def hidden_social_graph_redirect
    return if belongs_to_current_user? || !@user.privacy_hide_social_graph

    redirect_to user_path(@user)
  end

  def direct_param
    # return `nil` instead of `false` so we retrieve all questions for the user, direct or not.
    # `cursored_questions` will then remove the `direct` field from the WHERE query.  otherwise the query filters
    # for `WHERE direct = false` ...
    return if belongs_to_current_user? || moderation_view?

    # page is not being viewed by the current user, and we're not in the moderation view -> only show public questions
    false
  end

  def belongs_to_current_user? = @user == current_user
end
