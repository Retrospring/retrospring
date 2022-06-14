# frozen_string_literal: true

class RenameAuthorEmailToAuthorIdentifier < ActiveRecord::Migration[6.1]
  def change
    rename_column :questions, :author_email, :author_identifier
  end
end
