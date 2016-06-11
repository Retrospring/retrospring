class DiscoverController < ApplicationController
  before_filter :authenticate_user!

  def index
    top_x = 10  # only display the top X items

    @popular_answers = Answer.all.order(:smile_count).reverse_order.limit(top_x)
    @most_discussed = Answer.all.order(:comment_count).reverse_order.limit(top_x)
    @popular_questions = Question.all.order(:answer_count).reverse_order.limit(top_x)
    @new_users = User.where("asked_count > 0").order(:id).reverse_order.limit(top_x)

    # .user = the user
    # .question_count = how many questions did the user ask
    @users_with_most_questions = Question.all.select('user_id, COUNT(*) AS question_count').
        where(author_is_anonymous: false).
        group(:user_id).
        order('question_count').
        reverse_order.limit(top_x)

    # .user = the user
    # .answer_count = how many questions did the user answer
    @users_with_most_answers = Answer.all.select('user_id, COUNT(*) AS answer_count').
        group(:user_id).
        order('answer_count').
        reverse_order.limit(top_x)
  end
end
