include Warden::Test::Helpers
Warden.test_mode!

# Feature: Ban users
#   As a user
#   I want to get banned
#   So I can't sign in anymore
feature "Ban users", :devise do

  after :each do
    Warden.test_reset!
  end

  # Scenario: User gets banned
  #   Given I am signed in
  #   When I visit another page
  #   And I am banned
  #   Then I see the sign in page
  scenario "user gets banned", js: true do
    me = FactoryGirl.create :user

    login_as me, scope: :user
    visit root_path
    expect(page).to have_text("Timeline")
    page.driver.render Rails.root.join("tmp/ban_#{Time.now.to_i}_1.png"), full: true

    me.permanently_banned = true
    me.save

    visit "/inbox"

    expect(current_path).to eq(new_user_session_path)
    page.driver.render Rails.root.join("tmp/ban_#{Time.now.to_i}_2.png"), full: true
  end

  scenario 'user visits banned user profiles', js: true do
    evil_user = FactoryGirl.create :user
    evil_user.permanently_banned = true
    evil_user.save

    visit show_user_profile_path(evil_user.screen_name)
    expect(page).to have_text('BANNED')
    page.driver.render Rails.root.join("tmp/ban_#{Time.now.to_i}_3.png"), full: true
  end
end
