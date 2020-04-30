# frozen_string_literal: true

FactoryBot.define do
  factory :comment_smile do
    user { FactoryBot.build(:user) }
    comment { FactoryBot.build(:comment) }
  end
end
