class RenameColumnsInAnswers < ActiveRecord::Migration
  def change
    rename_column :answers, :comments, :comment_count
    remove_column :answers, :likes
    change_column :answers, :comment_count, :integer, default: 0, null: false
  end
end
