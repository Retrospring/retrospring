class RenameColumnsInAnswers < ActiveRecord::Migration[4.2]
  def change
    rename_column :answers, :comments, :comment_count
    remove_column :answers, :likes
    change_column :answers, :comment_count, :integer, default: 0, null: false
  end
end
