# frozen_string_literal: true

class RemoveTumblrConnections < ActiveRecord::Migration[5.2]
  def up
    execute %(DELETE FROM services WHERE type = 'Services::Tumblr';)
  end

  def down
    # won't have tumblr tokens anymore on rollback, but that's ok
  end
end
