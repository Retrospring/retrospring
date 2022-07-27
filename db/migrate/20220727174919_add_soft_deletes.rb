class AddSoftDeletes < ActiveRecord::Migration[6.1]
  def change
    %i[answers appendables comments questions users].each do |table|
      say "Migrating #{table}"
      add_column table, :deleted_at, :datetime
      add_index table, :deleted_at
    end
  end
end
