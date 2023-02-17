# frozen_string_literal: true

class AboutController < ApplicationController
  def index; end

  def about
    cache "about_counters", expires_in: 1.hour do
      user_count = User
                   .where.not(confirmed_at: nil)
                   .where("answered_count > 0")
                   .count

      current_ban_count = UserBan
                          .current
                          .joins(:user)
                          .where.not("users.confirmed_at": nil)
                          .where("users.answered_count > 0")
                          .count

      @users = user_count - current_ban_count
      @questions = Question.count(:id)
      @answers = Answer.count(:id)
      @comments = Comment.count(:id)
      @smiles = Appendable::Reaction.count
    end
  end

  def privacy_policy; end

  def terms; end
end
