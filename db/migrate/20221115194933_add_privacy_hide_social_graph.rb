# frozen_string_literal: true

class AddPrivacyHideSocialGraph < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :privacy_hide_social_graph, :boolean, default: false
  end

  def down
    remove_column :users, :privacy_hide_social_graph
  end
end
