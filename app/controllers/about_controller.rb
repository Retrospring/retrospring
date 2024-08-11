# frozen_string_literal: true

class AboutController < ApplicationController
  def index
    return unless Retrospring::Config.advanced_frontpage_enabled?

    render template: "about/index_advanced"
  end

  def about
    @users = Rails.cache.fetch("about_count_users", expires_in: 1.hour) { user_count - current_ban_count }
    @questions = Rails.cache.fetch("about_count_questions", expires_in: 1.hour) { Question.count(:id) }
    @answers = Rails.cache.fetch("about_count_answers", expires_in: 1.hour) { Answer.count(:id) }
    @comments = Rails.cache.fetch("about_count_comments", expires_in: 1.hour) { Comment.count(:id) }
  end

  def privacy_policy; end

  def terms; end

  private

  def user_count = User
    .where.not(confirmed_at: nil)
    .where("answered_count > 0")
    .count

  def current_ban_count = UserBan
    .current
    .joins(:user)
    .where.not("users.confirmed_at": nil)
    .where("users.answered_count > 0")
    .count
end
