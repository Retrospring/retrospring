# frozen_string_literal: true

class AddLastReportsVisitToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :last_reports_visit, :datetime
  end
end
