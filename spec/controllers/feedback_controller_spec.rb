# frozen_string_literal: true

require "rails_helper"

describe FeedbackController, type: :controller do
  before do
    stub_const("APP_CONFIG", {
                 "hostname"       => "example.com",
                 "https"          => true,
                 "items_per_page" => 5,
                 "canny"          => {
                   sso:           "sso",
                   feature_board: "feature",
                   bug_board:     "bug"
                 }
               })
  end

  describe "#consent" do
    context "user signed in without consent" do
      let(:user) { FactoryBot.create(:user) }

      before(:each) { sign_in(user) }

      it "renders the consent template" do
        get :consent
        expect(response).to render_template(:consent)
      end
    end

    context "user signed in with consent" do
      let(:user) { FactoryBot.create(:user, roles: [:canny_consent]) }

      before(:each) { sign_in(user) }

      it "redirects away from the consent page" do
        get :consent
        expect(response).to redirect_to(feedback_bugs_path)
      end
    end
  end

  describe "#update" do
    let(:user) { FactoryBot.create(:user) }

    before(:each) { sign_in(user) }

    it "sets the consent role" do
      post :update, params: { consent: "true" }
      expect(user.has_role?(:canny_consent)).to eq(true)
      expect(response).to redirect_to(feedback_bugs_path)
    end
  end

  describe "#features" do
    subject { get :features }

    context "user signed in with consent" do
      let(:user) { FactoryBot.create(:user, roles: [:canny_consent]) }

      before(:each) { sign_in(user) }

      it "renders the features template" do
        subject
        expect(response).to render_template(:features)
      end
    end

    context "user signed in without consent" do
      let(:user) { FactoryBot.create(:user) }

      before(:each) { sign_in(user) }

      it "redirects to the consent page" do
        subject
        expect(response).to redirect_to(feedback_consent_path)
      end
    end
  end

  describe "#bugs" do
    subject { get :bugs }

    context "user signed in with consent" do
      let(:user) { FactoryBot.create(:user, roles: [:canny_consent]) }

      before(:each) { sign_in(user) }

      it "renders the bugs template" do
        subject
        expect(response).to render_template(:bugs)
      end
    end

    context "user signed in without consent" do
      let(:user) { FactoryBot.create(:user) }

      before(:each) { sign_in(user) }

      it "redirects to the consent page" do
        subject
        expect(response).to redirect_to(feedback_consent_path)
      end
    end
  end
end
