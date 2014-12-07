class AddAnswerCountToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :answer_count, :integer, default: 0, null: false
  end
end
