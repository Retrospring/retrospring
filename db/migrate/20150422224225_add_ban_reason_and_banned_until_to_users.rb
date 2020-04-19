class AddBanReasonAndBannedUntilToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :ban_reason, :string, default: nil
    add_column :users, :banned_until, :datetime, default: nil
  end
end
