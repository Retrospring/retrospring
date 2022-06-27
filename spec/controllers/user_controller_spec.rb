# frozen_string_literal: true

require "rails_helper"

describe UserController, type: :controller do
  let(:user) { FactoryBot.create :user,
                                 otp_module: :disabled,
                                 otp_secret_key: 'EJFNIJPYXXTCQSRTQY6AG7XQLAT2IDG5H7NGLJE3'}

  describe "#show" do
    subject { get :show, params: { username: user.screen_name } }

    context "user signed in" do
      before(:each) { sign_in user }

      it "renders the user/show template" do
        subject
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template("user/show")
      end
    end
  end

  describe "#followers" do
    subject { get :followers, params: { username: user.screen_name } }

    context "user signed in" do
      before(:each) { sign_in user }

      it "renders the user/show_follow template" do
        subject
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template("user/show_follow")
      end
    end
  end

  describe "#followings" do
    subject { get :followings, params: { username: user.screen_name } }

    context "user signed in" do
      before(:each) { sign_in user }

      it "renders the user/show_follow template" do
        subject
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template("user/show_follow")
      end
    end
  end

  describe "#questions" do
    subject { get :questions, params: { username: user.screen_name } }

    context "user signed in" do
      before(:each) { sign_in user }

      it "renders the user/questions template" do
        subject
        expect(assigns(:user)).to eq(user)
        expect(response).to render_template("user/questions")
      end
    end
  end

  describe "#edit_security" do
    subject { get :edit_security }

    context "user signed in" do
      before(:each) { sign_in user }
      render_views

      it "shows a setup form for users who don't have 2FA enabled" do
        subject
        expect(response).to have_rendered(:edit_security)
        expect(response).to have_rendered(partial: 'settings/security/_totp_setup')
      end

      it "shows the option to disable 2FA for users who have 2FA already enabled" do
        user.otp_module = :enabled
        user.save

        subject
        expect(response).to have_rendered(:edit_security)
        expect(response).to have_rendered(partial: 'settings/security/_totp_enabled')
      end
    end
  end

  describe "#update_2fa" do
    subject { post :update_2fa, params: update_params }

    context "user signed in" do
      before(:each) { sign_in user }

      context "user enters the incorrect code" do
        let(:update_params) do
          {
              user: { otp_validation: 123456 }
          }
        end

        it "shows an error if the user enters the incorrect code" do
          Timecop.freeze(Time.at(1603290888)) do
            subject
            expect(response).to redirect_to :edit_user_security
            expect(flash[:error]).to eq('The code you entered was invalid.')
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
          Timecop.freeze(Time.at(1603290888)) do
            subject
            expect(response).to have_rendered(:recovery_keys)

            expect(user.totp_recovery_codes.count).to be(TotpRecoveryCode::NUMBER_OF_CODES_TO_GENERATE)
          end
        end

        it "shows an error if the user attempts to use the code once it has expired" do
          Timecop.freeze(Time.at(1603290950)) do
            subject
            expect(response).to redirect_to :edit_user_security
            expect(flash[:error]).to eq(I18n.t("errors.invalid_otp"))
          end
        end
      end
    end
  end

  describe "#destroy_2fa" do
    subject { delete :destroy_2fa }

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

  describe "#reset_user_recovery_codes" do
    subject { delete :reset_user_recovery_codes }

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

  describe "#edit_blocks" do
    subject { get :edit_blocks }

    context "user signed in" do
      before(:each) { sign_in user }

      it "shows the edit_blocks page" do
        subject
        expect(response).to have_rendered(:edit_blocks)
      end

      it "only contains blocks of the signed in user" do
        other_user = create(:user)
        other_user.block(user)

        subject

        expect(assigns(:blocks)).to eq(user.active_block_relationships)
      end

      it "only contains anonymous blocks of the signed in user" do
        other_user = create(:user)
        question = create(:question)
        other_user.anonymous_blocks.create(identifier: "very-real-identifier", question_id: question.id)

        subject

        expect(assigns(:anonymous_blocks)).to eq(user.anonymous_blocks)
      end
    end
  end
end
