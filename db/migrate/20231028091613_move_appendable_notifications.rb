# frozen_string_literal: true

class MoveAppendableNotifications < ActiveRecord::Migration[7.0]
  def up
    Notification::where(target_type: "Appendable").update_all(target_type: "Reaction") # rubocop:disable Rails/SkipsModelValidations
  end

  def down
    Notification::where(target_type: "Reaction").update_all(type: "Appendable") # rubocop:disable Rails/SkipsModelValidations
  end
end
