# frozen_string_literal: true

RSpec.shared_examples_for "requires login" do
  it "redirects to the login page for guests" do
    subject
    expect(response).to redirect_to(new_user_session_path)
  end

  it "does not redirect to the login page for users" do
    sign_in user
    subject
    expect(response).to_not redirect_to(new_user_session_path)
  end
end
