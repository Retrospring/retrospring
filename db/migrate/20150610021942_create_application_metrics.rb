class CreateApplicationMetrics < ActiveRecord::Migration
  def change
    create_table :application_metrics do |t|
      t.integer :application_id
      t.string :path
      t.string :params
      t.string :method
      t.integer :spent
      t.integer :dbtime
      t.integer :dbcalls
      t.integer :status

      t.timestamps null: false
    end
  end
end
