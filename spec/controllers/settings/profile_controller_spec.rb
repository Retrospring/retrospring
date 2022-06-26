# frozen_string_literal: true

require "rails_helper"

describe Settings::ProfileController, type: :controller do
  describe "#edit" do
    subject { get :edit }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before { sign_in user }

      it "renders the edit template" do
        subject
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "#update" do
    subject { patch :update, params: { profile: profile_params } }
    let(:profile_params) do
      {
        display_name: "sneaky cune"
      }
    end

    let(:user) { FactoryBot.create :user }

    context "user signed in" do
      before(:each) { sign_in user }

      it "updates the user's profile" do
        expect { subject }.to change { user.profile.reload.display_name }.to("sneaky cune")
      end

      it "redirects to the edit_user_profile page" do
        subject
        expect(response).to redirect_to(:settings_profile)
      end
    end
  end
end
