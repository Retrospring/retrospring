# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    sequence(:display_name) { |i| "#{Faker::Internet.username(specifier: 0..12, separators: %w[_])}#{i}" }
    user { FactoryBot.build(:user) }
  end
end
