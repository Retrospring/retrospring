# frozen_string_literal: true

require "rails_helper"

describe UserController, type: :controller do
  let(:user) { FactoryBot.create :user, otp_module: :disabled }

  describe "#edit" do
    subject { get :edit }

    context "user signed in" do
      before(:each) { sign_in user }

      it "renders the edit_profile_picture template" do
        subject
        expect(response).to render_template("user/edit")
      end
    end
  end

  describe "#update" do
    subject { patch :update, params: { user: avatar_params } }
    let(:avatar_params) do
      {
          profile_picture: fixture_file_upload("files/banana_racc.jpg", "image/jpeg")
      }
    end

    context "user signed in" do
      before(:each) { sign_in user }

      it "enqueues a Sidekiq job to process the uploaded profile picture" do
        subject
        expect(::CarrierWave::Workers::ProcessAsset).to have_enqueued_sidekiq_job("User", user.id.to_s, "profile_picture")
      end

      it "redirects to the edit_user_profile page" do
        subject
        expect(response).to redirect_to(:edit_user_profile)
      end
    end
  end

  describe "#update" do
    subject { patch :update, params: { user: header_params } }
    let(:header_params) do
      {
          profile_header: fixture_file_upload("files/banana_racc.jpg", "image/jpeg")
      }
    end

    context "user signed in" do
      before(:each) { sign_in user }

      it "enqueues a Sidekiq job to process the uploaded profile header" do
        subject
        expect(::CarrierWave::Workers::ProcessAsset).to have_enqueued_sidekiq_job("User", user.id.to_s, "profile_header")
      end

      it "redirects to the edit_user_profile page" do
        subject
        expect(response).to redirect_to(:edit_user_profile)
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
              user: { otp_secret_key: 'EJFNIJPYXXTCQSRTQY6AG7XQLAT2IDG5H7NGLJE3',
                      otp_validation: 123456 }
          }
        end

        it "shows an error if the user enters the incorrect code" do
          Timecop.freeze(Time.at(1603290888)) do
            subject
            expect(response).to redirect_to :edit_user_security
          end
        end
      end

      context "user enters the correct code" do
        let(:update_params) do
          {
              user: { otp_secret_key: 'EJFNIJPYXXTCQSRTQY6AG7XQLAT2IDG5H7NGLJE3',
                      otp_validation: 187894 }
          }
        end

        it "enables 2FA for the logged in user" do
          Timecop.freeze(Time.at(1603290888)) do
            subject
            expect(response).to redirect_to :edit_user_security
          end
        end

        it "shows an error if the user attempts to use the code once it has expired" do
          Timecop.freeze(Time.at(1603290910)) do
            subject
            expect(flash[:error]).to eq('The code you entered was invalid.')
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
        sign_in user
      end

      it "disables 2FA for the logged in user" do
        subject
        user.reload
        expect(user.otp_module_enabled?).to be_falsey
      end
    end
  end
end
