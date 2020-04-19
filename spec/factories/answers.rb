FactoryBot.define do
  factory :answer do |u|
    u.sequence(:content) { |n| "This is an answer.  I'm number #{n}!" }
    u.user { FactoryBot.create(:user) }
  end
end
