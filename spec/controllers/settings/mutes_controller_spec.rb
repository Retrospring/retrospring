# frozen_string_literal: true

require "rails_helper"

describe Settings::MutesController, type: :controller do
  describe "#index" do
    subject { get :index }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before { sign_in user }

      it "shows the index page" do
        subject
        expect(response).to have_rendered(:index)
      end
    end
  end

  describe "#create" do
    subject { post :create, params: { muted_phrase: "foo" }, format: :turbo_stream }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before { sign_in user }

      it "creates a mute rule" do
        expect { subject }.to(change { MuteRule.count }.by(1))
      end

      it "contains a turbo stream append tag" do
        subject

        expect(response.body).to include "turbo-stream action=\"append\" target=\"rules\""
      end
    end
  end

  describe "#destroy" do
    subject { delete :destroy, params:, format: :turbo_stream }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }
      let(:rule) { MuteRule.create(user:, muted_phrase: "foo") }
      let(:params) { { id: rule.id } }

      before { sign_in user }

      it "destroys a mute rule" do
        subject

        expect(MuteRule.exists?(rule.id)).to eq(false)
      end

      it "contains a turbo stream remove tag" do
        subject

        expect(response.body).to include "turbo-stream action=\"remove\" target=\"rule_#{rule.id}\""
      end
    end
  end
end
