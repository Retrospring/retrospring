# frozen_string_literal: true

class ChangeAnswerContentColumnType < ActiveRecord::Migration[4.2]
  def change
    change_table :answers do |t|
      t.change :content, :text
    end
  end
end
