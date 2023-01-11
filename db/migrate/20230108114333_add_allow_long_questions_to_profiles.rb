# frozen_string_literal: true

class AddAllowLongQuestionsToProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :allow_long_questions, :boolean, default: false
  end
end
