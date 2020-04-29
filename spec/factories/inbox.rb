# frozen_string_literal: true

FactoryBot.define do
  factory :inbox do
    question { FactoryBot.build(:question) }
    new { true }
  end
end
