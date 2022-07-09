# frozen_string_literal: true

FactoryBot.define do
  factory :smile, class: Appendable::Reaction do
    user { FactoryBot.create(:user) }
    parent { FactoryBot.create(:answer, user: FactoryBot.create(:user)) }
    content { "🙂" }
  end
end
