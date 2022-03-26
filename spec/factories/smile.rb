# frozen_string_literal: true

FactoryBot.define do
  factory :smile, class: Appendable::Reaction do
    user { FactoryBot.build(:user) }
    parent { FactoryBot.build(:answer) }
    content { "🙂" }
  end
end
