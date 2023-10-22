# frozen_string_literal: true

class AddReasonToReport < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :reason, :string, default: nil
  end
end
