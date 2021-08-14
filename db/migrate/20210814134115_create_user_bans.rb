class CreateUserBans < ActiveRecord::Migration[5.2]
  def up
    create_table :user_bans do |t|
      t.bigint :user_id
      t.string :reason
      t.datetime :expires_at
      t.bigint :banned_by_id, nullable: true

      t.timestamps
    end

    # foxy's functional fqueries
    execute "INSERT INTO user_bans
    (user_id, reason, expires_at, created_at, updated_at)
    SELECT users.id, users.ban_reason, users.banned_until, users.updated_at, NOW() FROM users
    WHERE banned_until IS NOT NULL AND NOT permanently_banned;"


    execute "INSERT INTO user_bans
    (user_id, reason, expires_at, created_at, updated_at)
    SELECT users.id, users.ban_reason, NULL, users.updated_at, NOW() FROM users
    WHERE permanently_banned;"
  end

  def down
    drop_table :user_bans
  end
end
