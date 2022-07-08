# frozen_string_literal: true

class CorrectNotificationTargetTypes < ActiveRecord::Migration[6.1]
  def up
    execute "UPDATE notifications SET target_type = 'Appendable' WHERE target_type = 'Appendable::Reaction'"

    execute "UPDATE notifications SET target_type = 'Relationship' WHERE target_type = 'Relationships::Follow'"
  end
end
