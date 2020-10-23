require 'rails_helper'

describe User::SessionsController do
  before do
    # Required for devise to register routes
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#create" do
    let(:user) { FactoryBot.create(:user, password: '/bin/animals64') }

    subject { post :create, params: { user: { login: user.email, password: user.password } } }

    it "logs in users without 2FA enabled without any further input" do
      expect(subject).to redirect_to :root
    end

    it "prompts users with 2FA enabled to enter a code" do
      user.otp_module = :enabled
      user.save

      expect(subject).to have_rendered('auth/two_factor_authentication')
    end
  end
end