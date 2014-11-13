class AddSmileCountToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :smile_count, :integer, default: 0, null: false
  end
end
