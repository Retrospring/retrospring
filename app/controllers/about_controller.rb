# frozen_string_literal: true

class AboutController < ApplicationController
  def index; end

  def about
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
    @questions = Question.count
    @answers = Answer.count
    @comments = Comment.count
    @smiles = Appendable::Reaction.count
  end

  def privacy_policy; end

  def terms; end
end
