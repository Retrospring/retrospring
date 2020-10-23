class AddOtpSecretKeyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :otp_secret_key, :string
    add_column :users, :otp_module, :integer, default: 0, null: false
  end
end
