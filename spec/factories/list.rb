# frozen_string_literal: true

FactoryBot.define do
  factory :list do
    sequence(:display_name) { |i| "#{Faker::Internet.username(specifier: 0..12, separators: %w[_])}#{i}" }
    user { FactoryBot.build(:user) }

    transient do
      members { [] }
    end

    after(:create) do |list, evaluator|
      evaluator.members.each do |member|
        ListMember.create(list_id: list.id, user_id: member.id)
      end
    end
  end
end
