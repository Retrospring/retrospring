# frozen_string_literal: true

class CreateAnnouncements < ActiveRecord::Migration[5.2]
  def change
    create_table :announcements do |t|
      t.text :content, null: false
      t.string :link_text
      t.string :link_href
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.belongs_to :user, null: false

      t.timestamps
    end
  end
end
