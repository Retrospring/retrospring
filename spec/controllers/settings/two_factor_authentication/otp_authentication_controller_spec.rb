# frozen_string_literal: true

require "rails_helper"

describe Settings::TwoFactorAuthentication::OtpAuthenticationController, type: :controller do
  let(:user) do
    FactoryBot.create :user,
                      otp_module:     :disabled,
                      otp_secret_key: "EJFNIJPYXXTCQSRTQY6AG7XQLAT2IDG5H7NGLJE3"
  end

  describe "#index" do
    subject { get :index }

    context "user signed in" do
      before(:each) { sign_in user }
      render_views

      it "shows a setup form for users who don't have 2FA enabled" do
        subject
        expect(response).to have_rendered(:index)
        expect(response).to have_rendered(partial: "settings/two_factor_authentication/otp_authentication/_totp_setup")
      end

      it "shows the option to disable 2FA for users who have 2FA already enabled" do
        user.otp_module = :enabled
        user.save

        subject
        expect(response).to have_rendered(:index)
        expect(response).to have_rendered(partial: "settings/two_factor_authentication/otp_authentication/_totp_enabled")
      end
    end
  end

  describe "#update" do
    subject { post :update, params: update_params }

    context "user signed in" do
      before(:each) { sign_in user }

      context "user enters the incorrect code" do
        let(:update_params) do
          {
            user: { otp_validation: 123456 }
          }
        end

        it "shows an error if the user enters the incorrect code" do
          Timecop.freeze(Time.at(1603290888).utc) do
            subject
            expect(response).to redirect_to :settings_two_factor_authentication_otp_authentication
            expect(flash[:error]).to eq("The code you entered was invalid.")
          end
        end
      end

      context "user enters the correct code" do
        let(:update_params) do
          {
            user: { otp_validation: 187894 }
          }
        end

        it "enables 2FA for the logged in user and generates recovery keys" do
          Timecop.freeze(Time.at(1603290888).utc) do
            subject
            expect(response).to have_rendered(:recovery_keys)

            expect(user.totp_recovery_codes.count).to be(TotpRecoveryCode::NUMBER_OF_CODES_TO_GENERATE)
          end
        end

        it "shows an error if the user attempts to use the code once it has expired" do
          Timecop.freeze(Time.at(1603290950).utc) do
            subject
            expect(response).to redirect_to :settings_two_factor_authentication_otp_authentication
            expect(flash[:error]).to eq(I18n.t("errors.invalid_otp"))
          end
        end
      end
    end
  end

  describe "#destroy" do
    subject { delete :destroy }

    context "user signed in" do
      before(:each) do
        user.otp_module = :enabled
        user.save
        sign_in(user)
      end

      it "disables 2FA for the logged in user" do
        subject
        user.reload
        expect(user.otp_module_enabled?).to be_falsey
        expect(user.totp_recovery_codes.count).to be(0)
      end
    end
  end

  describe "#reset" do
    subject { delete :reset }

    context "user signed in" do
      before(:each) do
        sign_in(user)
      end

      it "regenerates codes on request" do
        old_codes = user.totp_recovery_codes.pluck(:code)
        subject
        new_codes = user.totp_recovery_codes.pluck(:code)
        expect(new_codes).not_to match_array(old_codes)
      end
    end
  end
end
