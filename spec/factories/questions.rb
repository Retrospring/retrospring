FactoryGirl.define do
  factory :question do |u|
    u.sequence(:content) { |n| "#{QuestionGenerator.generate}#{n}" }
    u.author_is_anonymous true
  end
end
