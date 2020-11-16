class TotpRecoveryCode < ApplicationRecord
  NUMBER_OF_CODES_TO_GENERATE = 16

  belongs_to :user

  # @param user [User]
  # @return [Array<TotpRecoveryCode>]
  def self.generate_for(user)
    TotpRecoveryCode.create!(Array.new(16) { {user: user, code: SecureRandom.base58(8).downcase} })
  end
end
