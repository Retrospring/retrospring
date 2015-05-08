FactoryGirl.define do
  factory :answer do |u|
    u.sequence(:content) { |n| "This is an answer.  I'm number #{n}!" }
    u.user FactoryGirl.create(:user)
  end
end
