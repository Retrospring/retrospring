FactoryGirl.define do
  factory :user do |u|
    u.sequence(:screen_name) { |n| "#{Faker::Internet.user_name 0..12, %w(_)}#{n}" }
    u.sequence(:email) { |n| "#{n}#{Faker::Internet.email}" }
    u.password "P4s5w0rD"
    u.sequence(:confirmed_at) { Time.zone.now }
    u.display_name { Faker::Name.name }
  end
end
