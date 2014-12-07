module Features
  module SessionHelpers
    def sign_up_with(screen_name, email, password, confirmation)
      visit new_user_registration_path
      fill_in 'User name', with: screen_name
      fill_in 'Email address', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', :with => confirmation
      click_button 'Sign up'
    end

    def signin(email, password)
      visit new_user_session_path
      fill_in 'User name', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end
  end
end