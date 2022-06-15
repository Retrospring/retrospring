# frozen_string_literal: true

class AnonymousBlock < ApplicationRecord
  belongs_to :user
  belongs_to :question, optional: true

  def self.get_identifier(ip)
    Digest::SHA2.new(512).hexdigest(Rails.application.secret_key_base + ip)
  end
end
