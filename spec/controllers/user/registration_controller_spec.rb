# frozen_string_literal: true

require "rails_helper"

describe User::RegistrationsController, type: :controller do
  before do
    # Required for devise to register routes
    @request.env["devise.mapping"] = Devise.mappings[:user]

    stub_const("APP_CONFIG", {
                 "hostname"               => "example.com",
                 "https"                  => true,
                 "items_per_page"         => 5,
                 "forbidden_screen_names" => %w[
                   justask_admin retrospring_admin admin justask retrospring
                   moderation moderator mod administrator siteadmin site_admin
                   help retro_spring retroospring retrosprlng
                 ],
               },)
  end

  describe "#create" do
    context "valid user sign up" do
      before do
        allow(APP_CONFIG).to receive(:dig).with(:hcaptcha, :enabled).and_return(true)
        allow(APP_CONFIG).to receive(:dig).with(:features, :registration, :enabled).and_return(true)
      end

      let :registration_params do
        {
          user: {
            screen_name:           "dio",
            email:                 "the-world-21@somewhere.everywhere.now",
            password:              "AReallySecurePassword456!",
            password_confirmation: "AReallySecurePassword456!",
          },
        }
      end

      subject { post :create, params: registration_params }

      context "when captcha is invalid" do
        before do
          allow(controller).to receive(:verify_hcaptcha).and_return(false)
        end

        it "doesn't allow a registration with an invalid captcha" do
          expect { subject }.not_to(change { User.count })
          expect(response).to redirect_to :new_user_registration
        end
      end

      context "when captcha is valid" do
        before do
          allow(controller).to receive(:verify_hcaptcha).and_return(true)
        end

        it "creates a user" do
          allow(controller).to receive(:verify_hcaptcha).and_return(true)
          expect { subject }.to change { User.count }.by(1)
        end
      end

      context "when registrations are disabled" do
        before do
          allow(APP_CONFIG).to receive(:dig).with(:hcaptcha, :enabled).and_return(false)
          allow(APP_CONFIG).to receive(:dig).with(:features, :registration, :enabled).and_return(false)
        end

        it "redirects to the root page" do
          allow(controller).to receive(:verify_hcaptcha).and_return(true)
          subject
          expect(response).to redirect_to(root_path)
        end

        it "does not create a user" do
          allow(controller).to receive(:verify_hcaptcha).and_return(true)
          expect { subject }.not_to(change { User.count })
        end
      end
    end

    context "invalid user sign up" do
      before do
        allow(APP_CONFIG).to receive(:dig).with(:hcaptcha, :enabled).and_return(false)
        allow(APP_CONFIG).to receive(:dig).with(:features, :registration, :enabled).and_return(true)
      end

      subject { post :create, params: registration_params }

      context "when registration params are empty" do
        let(:registration_params) do
          {
            user: {
              screen_name:           "",
              email:                 "",
              password:              "",
              password_confirmation: "",
            },
          }
        end

        it "does not create a user" do
          expect { subject }.not_to(change { User.count })
        end
      end

      context "when username contains invalid characters" do
        let(:registration_params) do
          {
            user: {
              screen_name:           "Dio Brando",
              email:                 "the-world-21@somewhere.everywhere.now",
              password:              "AReallySecurePassword456!",
              password_confirmation: "AReallySecurePassword456!",
            },
          }
        end

        it "does not create a user" do
          expect { subject }.not_to(change { User.count })
        end
      end

      context "when username is forbidden" do
        let(:registration_params) do
          {
            user: {
              screen_name:           "moderator",
              email:                 "the-world-21@somewhere.everywhere.now",
              password:              "AReallySecurePassword456!",
              password_confirmation: "AReallySecurePassword456!",
            },
          }
        end

        it "does not create a user" do
          expect { subject }.not_to(change { User.count })
        end
      end
    end
  end

  describe "#new" do
    subject { get :new }

    context "when registrations are disabled" do
      before do
        allow(APP_CONFIG).to receive(:dig).with(:hcaptcha, :enabled).and_return(false)
        allow(APP_CONFIG).to receive(:dig).with(:features, :registration, :enabled).and_return(false)
      end

      it "redirects to the root page" do
        subject
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
