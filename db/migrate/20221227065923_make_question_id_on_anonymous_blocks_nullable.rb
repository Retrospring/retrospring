# frozen_string_literal: true

class MakeQuestionIdOnAnonymousBlocksNullable < ActiveRecord::Migration[6.1]
  def change
    change_column_null :anonymous_blocks, :question_id, true
  end
end
