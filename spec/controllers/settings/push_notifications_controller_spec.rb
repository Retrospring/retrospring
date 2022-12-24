# frozen_string_literal: true

require "rails_helper"

describe Settings::PushNotificationsController, type: :controller do
  describe "#index" do
    subject { get :index }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before { sign_in user }

      it "renders the index template" do
        subject
        expect(response).to render_template(:index)
      end
    end
  end
end
