require 'rails_helper'

describe User::SessionsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#two_factor_entry" do
    subject { get :two_factor_entry }
    it "redirects back to the home page if no sign in target is set" do
      expect(subject).to redirect_to :root
    end
  end
end