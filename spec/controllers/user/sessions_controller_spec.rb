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

    context "2fa sign in attempt" do
      subject do
        post :create,
             params: { user: { otp_attempt: code_input } },
             session: { user_sign_in_uid: user.id }
      end

      before do
        user.otp_module = :enabled
        user.save
      end

      context "incorrect code" do
        let(:code_input) { 123456 }

        it "redirects to the sign in page" do
          expect(subject).to redirect_to :new_user_session
        end
      end

      context "correct code" do
        let(:code_input) { user.otp_code }

        it "redirects to the timeline" do
          expect(subject).to redirect_to :root
        end
      end

      context "correct recovery code" do
        let(:code_input) { 'raccoons' }

        before do
          user.totp_recovery_codes << TotpRecoveryCode.create(code: 'raccoons')
        end

        it "consumes the recovery code" do
          expect { subject }.to change { user.totp_recovery_codes.count }.by(-1)
          expect(response).to redirect_to :root
        end
      end

      context "incorrect recovery code" do
        let(:code_input) { 'abcdefgh' }

        it "redirects to the sign in page" do
          expect(subject).to redirect_to :new_user_session
          expect(flash[:error]).to eq I18n.t("errors.invalid_otp")
        end
      end
    end
  end
end