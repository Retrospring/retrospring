# frozen_string_literal: true

class IncludeTypeInRelationshipUniqueConstraint < ActiveRecord::Migration[6.1]
  def change
    change_table :relationships do |t|
      t.remove_index(%i[source_id target_id])
      t.index(%i[source_id target_id type], unique: true)
    end
  end
end
