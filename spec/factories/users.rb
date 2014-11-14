FactoryGirl.define do
  factory :user do |u|
    u.screen_name { Faker::Internet.user_name 0..16, %w(_) }
    u.email { Faker::Internet.email }
    u.password { Faker::Internet.password }
    u.display_name { Faker::Name.name }
  end
end
