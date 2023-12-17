# frozen_string_literal: true

require "rails_helper"

describe Settings::ProfilePictureController, type: :controller do
  describe "#update" do
    subject { patch :update, params: { user: avatar_params } }

    before do
      if ENV["USE_FOG_IN_TESTS"].blank?
        stub_const("APP_CONFIG", {
                     "fog" => {},
                   })
      end
    end

    let(:avatar_params) do
      {
        profile_picture: fixture_file_upload("banana_racc.jpg", "image/jpeg"),
      }
    end

    let(:user) { FactoryBot.create :user }

    context "user signed in" do
      before(:each) { sign_in user }

      it "enqueues a Sidekiq job to process the uploaded profile picture" do
        subject
        expect(CarrierWave::Workers::ProcessAsset).to have_enqueued_sidekiq_job("User", user.id.to_s, "profile_picture")
      end

      it "redirects to the edit_user_profile page" do
        subject
        expect(response).to have_http_status(:ok)
        expect(response).to have_rendered(:edit)
      end
    end
  end
end
