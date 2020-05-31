# frozen_string_literal: true

require "rails_helper"

describe UserController, type: :controller do
  let(:user) { FactoryBot.create :user }

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
end
