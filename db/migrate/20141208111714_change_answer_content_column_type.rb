class ChangeAnswerContentColumnType < ActiveRecord::Migration
  def change
    change_table :answers do |t|
      t.change :content, :text
    end
  end
end
