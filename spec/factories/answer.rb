# frozen_string_literal: true

FactoryBot.define do
  factory :answer do
    transient do
      question_content { Faker::Lorem.sentence }
    end

    content { Faker::Lorem.sentence }
    question { FactoryBot.build(:question, content: question_content) }
  end
end
