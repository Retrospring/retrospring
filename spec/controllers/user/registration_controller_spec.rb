# frozen_string_literal: true

require "rails_helper"

describe User::RegistrationsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#create" do
    context "valid user sign up" do
      let :registration_params do
        {
            user: {
                screen_name: 'dio',
                email: 'the-world-21@somewhere.everywhere',
                password: 'AReallySecurePassword456!',
                password_confirmation: 'AReallySecurePassword456!'
            }
        }
      end

      subject { post :create, params: registration_params }

      it "doesn't allow a registration without solving the captcha" do
        expect { subject }.not_to(change { User.count })
        expect(response).to redirect_to :new_user_registration
      end

      it "creates a user" do
        allow(controller).to receive(:verify_hcaptcha).and_return(true)
        expect { subject }.to change { User.count }.by(1)
      end
    end

    context "invalid user sign up" do
      subject { post :create, params: registration_params }

      let!(:registration_params) { {} }
      it "rejects unfilled registration forms" do
        expect { subject }.not_to(change { User.count })
      end

      let!(:registration_params) { {
          user: {
              screen_name: 'Dio Brando',
              email: 'the-world-21@somewhere.everywhere',
              password: 'AReallySecurePassword456!',
              password_confirmation: 'AReallySecurePassword456!'
          }
      } }
      it "rejects registrations with invalid usernames" do
        expect { subject }.not_to(change { User.count })
      end

      let!(:registration_params) { {
          user: {
              screen_name: 'inbox',
              email: 'the-world-21@somewhere.everywhere',
              password: 'AReallySecurePassword456!',
              password_confirmation: 'AReallySecurePassword456!'
          }
      } }
      it "rejects registrations with reserved usernames" do
        expect { subject }.not_to(change { User.count })
      end
    end
  end
end
