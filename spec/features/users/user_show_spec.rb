include Warden::Test::Helpers
Warden.test_mode!

# Feature: User profile page
#   As a user
#   I want to visit my user profile page
#   So I can see my personal account data
feature "User profile page", :devise do

  after :each do
    Warden.test_reset!
  end

  # Scenario: User sees own profile
  #   Given I am signed in
  #   When I visit the user profile page
  #   Then I see my own screen name and follower count
  scenario 'user sees own profile', js: true do
    user = FactoryGirl.create(:user)

    login_as(user, :scope => :user)

    visit show_user_profile_path(user.screen_name)

    expect(page).to have_content user.screen_name
    expect(page).to have_content user.follower_count
  end

  # Scenario: User sees another user's profile
  #   Given I am signed in
  #   When I visit another user's profile
  #   Then I see that user's screen name and follower count
  scenario "user sees another user's profile", js: true do
    me = FactoryGirl.create(:user)
    other = FactoryGirl.create(:user)

    login_as me, scope: :user

    visit show_user_profile_path(other.screen_name)

    expect(page).to have_content other.screen_name
    expect(page).to have_content other.follower_count
  end

  # Scenario: User gets asked a question
  #   Given I am signed in
  #   When I visit another user's profile
  #    And I fill something in the question box
  #    And I click on "Ask"
  #   Then I see "Question asked successfully."
  scenario "user gets asked a question", js: true do
    me = FactoryGirl.create(:user)
    other = FactoryGirl.create(:user)

    login_as me, scope: :user
    visit show_user_profile_path(other.screen_name)
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_1.png"), full: true

    fill_in "qb-question", with: Faker::Lorem.sentence
    click_button "Ask"
    wait_for_ajax
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_2.png"), full: true

    expect(page).to have_text("Question asked successfully.")
  end
end
