# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    sequence(:display_name) { |i| "#{Faker::Internet.username(specifier: 0..12, separators: %w[_])}#{i}" }
    user { FactoryBot.build(:user) }

    transient do
      members { [] }
    end

    after(:create) do |group, evaluator|
      evaluator.members.each do |member|
        GroupMember.create(group_id: group.id, user_id: member.id)
      end
    end
  end
end
