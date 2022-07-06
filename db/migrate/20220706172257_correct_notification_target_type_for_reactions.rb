# frozen_string_literal: true

class CorrectNotificationTargetTypeForReactions < ActiveRecord::Migration[6.1]
  def up
    execute "update notifications set target_type = 'Appendable::Reaction' where target_type = 'Appendable';"
  end
end
