# frozen_string_literal: true

require "rails_helper"

describe Settings::ProfilePictureController, type: :controller do
  describe "#update" do
    subject { patch :update, params: { user: user_params } }

    let(:user) { FactoryBot.create :user }

    context "user signed in" do
      before(:each) { sign_in user }

      context "updating profile picture" do
        let(:user_params) do
          {
            profile_picture: fixture_file_upload("banana_racc.jpg", "image/jpeg")
          }
        end

        it "enqueues a Sidekiq job to process the uploaded profile picture" do
          subject
          expect(CarrierWave::Workers::ProcessAsset).to have_enqueued_sidekiq_job("User", user.id.to_s, "profile_picture")
        end

        it "redirects to the edit_user_profile page" do
          subject
          expect(flash[:success]).to eq(I18n.t("settings.profile_picture.update.success.profile_picture"))
          expect(response).to redirect_to(:settings_profile)
        end
      end

      context "updating profile header" do
        let(:user_params) do
          {
            profile_header: fixture_file_upload("banana_racc.jpg", "image/jpeg")
          }
        end

        context "user signed in" do
          before(:each) { sign_in user }

          it "enqueues a Sidekiq job to process the uploaded profile header" do
            subject
            expect(CarrierWave::Workers::ProcessAsset).to have_enqueued_sidekiq_job("User", user.id.to_s, "profile_header")
          end

          it "redirects to the edit_user_profile page" do
            subject
            expect(flash[:success]).to eq(I18n.t("settings.profile_picture.update.success.profile_header"))
            expect(response).to redirect_to(:settings_profile)
          end
        end
      end

      context "updating both profile picture and header" do
        let(:user_params) do
          {
            profile_picture: fixture_file_upload("banana_racc.jpg", "image/jpeg"),
            profile_header:  fixture_file_upload("banana_racc.jpg", "image/jpeg")
          }
        end

        context "user signed in" do
          before(:each) { sign_in user }

          it "enqueues 2 Sidekiq jobs to process the uploaded images" do
            subject
            expect(CarrierWave::Workers::ProcessAsset).to have_enqueued_sidekiq_job("User", user.id.to_s, "profile_picture")
            expect(CarrierWave::Workers::ProcessAsset).to have_enqueued_sidekiq_job("User", user.id.to_s, "profile_header")
          end

          it "redirects to the edit_user_profile page" do
            subject
            expect(flash[:success]).to eq(I18n.t("settings.profile_picture.update.success.both"))
            expect(response).to redirect_to(:settings_profile)
          end
        end
      end

      context "setting show foreign themes to false" do
        let(:user_params) do
          { show_foreign_themes: false }
        end

        it "updates the user's show foreign themes setting" do
          expect { subject }.to change { user.reload.show_foreign_themes }.from(true).to(false)
          expect(flash[:success]).to eq(I18n.t("settings.profile_picture.update.success.foreign_themes.disabled"))
        end
      end

      context "setting show foreign themes to false" do
        before do
          user.update(show_foreign_themes: false)
        end

        let(:user_params) do
          { show_foreign_themes: true }
        end

        it "updates the user's show foreign themes setting" do
          expect { subject }.to change { user.reload.show_foreign_themes }.from(false).to(true)
          expect(flash[:success]).to eq(I18n.t("settings.profile_picture.update.success.foreign_themes.enabled"))
        end
      end
    end
  end
end
