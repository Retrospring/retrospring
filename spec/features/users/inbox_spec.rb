include Warden::Test::Helpers
Warden.test_mode!

# Feature: Answer questions
#   As a user
#   I want to go to the inbox
#   So I can answer and get new questions
feature "Inbox", :devise do

  after :each do
    Warden.test_reset!
  end

  # Scenario: User answers a question
  #   Given I am signed in
  #   When I visit the inbox
  #   And I have a question in my inbox
  #   Then I can answer my question
  #   And see the answer on my user profile
  scenario "user answers a question", js: true do
    me = FactoryGirl.create :user
    question = FactoryGirl.create :question
    Inbox.create question: question, user: me, new: true

    login_as me, scope: :user
    visit root_path

    click_link "Inbox"
    expect(page).to have_text(question.content)
    fill_in "ib-answer", with: Faker::Lorem.sentence
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_2.png"), full: true

    click_button "Answer"
    wait_for_ajax
    expect(page).not_to have_text(question.content)
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_3.png"), full: true

    visit show_user_profile_path(me.screen_name)
    expect(page).to have_text(question.content)
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_4.png"), full: true
  end

  # Scenario: User generates new question
  #   Given I am signed in
  #   When I visit the inbox
  #   And I click "Get new question"
  #   Then I get a new question
  scenario 'user generates new question', js: true do
    me = FactoryGirl.create :user

    login_as me, scope: :user
    visit inbox_path
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_1.png"), full: true

    click_button "Get new question"
    wait_for_ajax
    expect(page).to have_text('Answer')
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_2.png"), full: true
  end

  # Scenario: User with privacy options generates new question
  #   Given I am signed in
  #   When I visit the inbox
  #   And I click "Get new question"
  #   And I don't want to receive questions by anonymous users
  #   Then I get a new question
  scenario 'user with privacy options generates new question', js: true do
    me = FactoryGirl.create :user
    me.privacy_allow_anonymous_questions = false
    me.save

    login_as me, scope: :user
    visit inbox_path
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_1.png"), full: true

    click_button "Get new question"
    wait_for_ajax
    expect(page).to have_text('Answer')
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_2.png"), full: true
  end

=begin
  # Scenario: User deletes a question
  #   Given I am signed in
  #   When I visit the inbox
  #   And I have a question in my inbox
  #   And I delete the question
  #   Then don't see it anymore in my inbox
  scenario "user deletes a question", js: true do
    me = FactoryGirl.create :user
    question = FactoryGirl.create :question
    Inbox.create question: question, user: me

    login_as me, scope: :user
    visit inbox_path
    expect(page).to have_text(question.content)

    click_button "Delete"
    expect(page).to have_text('Really delete?')
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_1.png"), full: true

    # this apparently doesn't get triggered :(
    page.find('.sweet-alert').click_button 'Delete'
    wait_for_ajax

    login_as me, scope: :user
    visit inbox_path
    expect(page).not_to have_text(question.content)
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_2.png"), full: true
  end

  # Scenario: User deletes all questions
  #   Given I am signed in
  #   When I visit the inbox
  #   And I have a few questions in my inbox
  #   And I click on "Delete all questions"
  #   Then don't see them anymore in my inbox
  scenario "user deletes all questions", js: true do
    me = FactoryGirl.create :user
    5.times do
      question = FactoryGirl.create :question
      Inbox.create question: question, user: me
    end

    login_as me, scope: :user
    visit inbox_path
    expect(page).to have_text('Answer'.upcase)

    click_button "Delete all questions"
    expect(page).to have_text('Really delete 5 questions?')
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_1.png"), full: true

    page.find('.sweet-alert').click_button 'Delete'
    wait_for_ajax

    puts me.inbox.all

    login_as me, scope: :user
    visit inbox_path
    page.driver.render Rails.root.join("tmp/#{Time.now.to_i}_2.png"), full: true
    expect(page).not_to have_text('Answer'.upcase)
  end
=end
end
