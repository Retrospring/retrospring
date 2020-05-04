# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    transient do
      answer_content { Faker::Lorem.sentence }
    end

    content { Faker::Lorem.sentence }
    answer { FactoryBot.build(:answer, content: answer_content) }
  end
end
