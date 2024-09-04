# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:screen_name) { |i| "#{Faker::Internet.username(specifier: 0..12, separators: %w[_])}#{i}" }
    sequence(:email) { |i| "#{i}#{Faker::Internet.email}" }
    password { 'P4s5w0rD' }
    confirmed_at { Time.now.utc }

    transient do
      roles { [] }
      profile { { display_name: Faker::Name.name } }
    end

    after(:create) do |user, evaluator|
      evaluator.roles.each do |role|
        user.add_role role
      end

      evaluator.profile.each do |key, value|
        user.profile.public_send(:"#{key}=", value)
      end
    end
  end
end
