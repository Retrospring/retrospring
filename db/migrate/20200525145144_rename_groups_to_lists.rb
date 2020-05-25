# frozen_string_literal: true

class RenameGroupsToLists < ActiveRecord::Migration[5.2]
  def change
    say "Renaming group-related tables"
    rename_table :groups, :lists
    rename_table :group_members, :list_members

    say "Renaming group-related columns"
    rename_column :list_members, :group_id, :list_id

    say "Cleaning up unused/already covered indexes"
    # Rails already renames the indexes for us when we rename tables or columns.
    # Neat!
    remove_index :list_members, name: "index_list_members_on_list_id"
    remove_index :list_members, name: "index_list_members_on_user_id"
    remove_index :lists, name: "index_lists_on_name"
    remove_index :lists, name: "index_lists_on_user_id"
  end
end
