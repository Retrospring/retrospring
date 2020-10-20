require 'rails_helper'

describe User::SessionsController do
  before do
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

      expect(subject).to redirect_to :user_two_factor_entry
    end
  end

  describe "#two_factor_entry" do
    subject { get :two_factor_entry }

    it "redirects back to the home page if no sign in target is set" do
      expect(subject).to redirect_to :root
    end
  end
end