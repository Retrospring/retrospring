# frozen_string_literal: true

class WebPushSubscription < ApplicationRecord
  belongs_to :user

  scope :active, -> { where(failures: ...3) }
  scope :failed, -> { where(failures: 3..) }
end
