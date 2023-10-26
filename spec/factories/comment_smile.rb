# frozen_string_literal: true

FactoryBot.define do
  factory :comment_smile, class: Reaction do
    user { FactoryBot.build(:user) }
    parent { FactoryBot.build(:comment) }
    content { "🙂" }
  end
end
