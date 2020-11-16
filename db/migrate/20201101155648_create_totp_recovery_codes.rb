class CreateTotpRecoveryCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :totp_recovery_codes do |t|
      t.bigint :user_id
      t.string :code, limit: 8
    end
    add_index :totp_recovery_codes, [:user_id, :code]
  end
end
