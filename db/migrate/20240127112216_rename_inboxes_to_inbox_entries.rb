# frozen_string_literal: true

class RenameInboxesToInboxEntries < ActiveRecord::Migration[7.0]
  def change
    rename_table :inboxes, :inbox_entries
  end
end
