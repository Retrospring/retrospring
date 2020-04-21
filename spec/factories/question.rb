# frozen_string_literal: true

FactoryBot.define do
  factory :question do
    user { nil }
    content { Faker::Lorem.sentence }
    author_is_anonymous { true }
  end
end
