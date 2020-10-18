class AddOtpSecretKeyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :otp_secret_key, :string
  end
end
