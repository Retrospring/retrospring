# frozen_string_literal: true

FactoryBot.define do
  factory :inbox_entry do
    question { FactoryBot.build(:question) }
    new { true }
  end
end
