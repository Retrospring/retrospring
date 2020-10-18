class AddOtpSecretKeyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :otp_secret_key, :string
    add_column :users, :otp_module, :integer, default: 0, null: false

    User.find_each do |user|
      user.update_attribute(:otp_secret_key, User.otp_random_secret)
    end
  end
end
