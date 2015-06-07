include Warden::Test::Helpers
Warden.test_mode!

feature "User profile page", :devise do

  after :each do
    Warden.test_reset!
  end

  scenario "user gets followed", js: true do
    me = FactoryGirl.create(:user)
    other = FactoryGirl.create(:user)

    login_as me, scope: :user
    visit show_user_profile_path(other.screen_name)
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_1.png"), full: true

    click_button "Follow"
    wait_for_ajax
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_2.png"), full: true

    expect(page).to have_text("FOLLOWING")

    click_link 'Follower'
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_3.png"), full: true
    expect(page).to have_text(me.screen_name)
  end
end
