# frozen_string_literal: true

require "rails_helper"

describe User::RegistrationsController, type: :controller do
  before do
    # Required for devise to register routes
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#create" do
    context "valid user sign up" do
      before do
        allow(APP_CONFIG).to receive(:dig).with(:hcaptcha, :enabled).and_return(true)
        allow(controller).to receive(:verify_hcaptcha).and_return(captcha_successful)
      end

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

      context "when captcha is invalid" do
        let(:captcha_successful) { false }
        it "doesn't allow a registration with an invalid captcha" do
          expect { subject }.not_to(change { User.count })
          expect(response).to redirect_to :new_user_registration
        end
      end

      context "when captcha is valid" do
        let(:captcha_successful) { true }
        it "creates a user" do
          allow(controller).to receive(:verify_hcaptcha).and_return(true)
          expect { subject }.to change { User.count }.by(1)
        end
      end
    end

    context "invalid user sign up" do
      before do
        allow(APP_CONFIG).to receive(:dig).with(:hcaptcha, :enabled).and_return(false)
      end

      subject { post :create, params: registration_params }

      context "when registration params are empty" do
        let(:registration_params) do
          {
              user: {
                  screen_name: '',
                  email: '',
                  password: '',
                  password_confirmation: ''
              }
          }
        end

        it "does not create a user" do
          expect { subject }.not_to(change { User.count })
        end
      end

      context "when username contains invalid characters" do
        let(:registration_params) { {
            user: {
                screen_name: 'Dio Brando',
                email: 'the-world-21@somewhere.everywhere',
                password: 'AReallySecurePassword456!',
                password_confirmation: 'AReallySecurePassword456!'
            }
        } }

        it "does not create a user" do
          expect { subject }.not_to(change { User.count })
        end
      end

      context "when username is forbidden" do
        let(:registration_params) { {
            user: {
                screen_name: 'inbox',
                email: 'the-world-21@somewhere.everywhere',
                password: 'AReallySecurePassword456!',
                password_confirmation: 'AReallySecurePassword456!'
            }
        } }

        it "does not create a user" do
          expect { subject }.not_to(change { User.count })
        end
      end
    end
  end
end
