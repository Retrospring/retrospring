# frozen_string_literal: true

require "rails_helper"

describe Admin::DashboardController, type: :controller do
  describe "#index" do
    subject { get :index }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user, roles: [:administrator]) }

      before { sign_in user }

      it "shows the index page" do
        subject
        expect(response).to have_rendered(:index)
      end
    end
  end
end
