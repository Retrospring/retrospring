# frozen_string_literal: true

class AddTargetUserToReports < ActiveRecord::Migration[7.0]
  def up
    add_reference :reports, :target_user, null: true, foreign_key: false

    execute <<~SQL.squish
      UPDATE reports
      SET target_user_id = users.id
      FROM users
      WHERE users.id = reports.target_id AND reports.type = 'Reports::User'
    SQL

    execute <<~SQL.squish
      UPDATE reports
      SET target_user_id = users.id
      FROM users, comments
      WHERE users.id = comments.user_id AND comments.id = reports.target_id AND reports.type = 'Reports::Comment'
    SQL

    execute <<~SQL.squish
      UPDATE reports
      SET target_user_id = users.id
      FROM users, answers
      WHERE users.id = answers.user_id AND answers.id = reports.target_id AND reports.type = 'Reports::Answer'
    SQL

    execute <<~SQL.squish
      UPDATE reports
      SET target_user_id = users.id
      FROM users, questions
      WHERE users.id = questions.user_id AND questions.id = reports.target_id AND reports.type = 'Reports::Question'
    SQL
  end

  def down
    remove_reference :reports, :target_user, null: true, foreign_key: false
  end
end
