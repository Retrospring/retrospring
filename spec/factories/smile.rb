# frozen_string_literal: true

FactoryBot.define do
  factory :smile do
    user { FactoryBot.build(:user) }
    answer { FactoryBot.build(:answer) }
  end
end
