# frozen_string_literal: true

require "rails_helper"

describe Settings::PrivacyController, type: :controller do
  let(:user) { FactoryBot.create(:user) }

  describe "#edit" do
    subject { get :edit }

    context "user signed in" do
      before(:each) { sign_in user }

      it "renders the edit template" do
        subject
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "#update" do
    subject { patch :update, params: { user: user_params } }
    let(:user_params) do
      {
        privacy_allow_anonymous_questions: false,
        privacy_allow_public_timeline:     false,
        privacy_allow_stranger_answers:    false,
        privacy_show_in_search:            false
      }
    end

    context "user signed in" do
      before(:each) { sign_in user }

      it "updates the user's profile" do
        subject
        user.reload
        expect(user.privacy_allow_anonymous_questions).to eq(false)
        expect(user.privacy_allow_public_timeline).to eq(false)
        expect(user.privacy_allow_stranger_answers).to eq(false)
        expect(user.privacy_show_in_search).to eq(false)
      end

      it "redirects to the privacy settings page" do
        subject
        expect(response).to render_template(:edit)
      end
    end
  end
end
