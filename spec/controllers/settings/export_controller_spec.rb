# frozen_string_literal: true

require "rails_helper"

describe Settings::ExportController, type: :controller do
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

  describe "#create" do
    subject { post :create }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before { sign_in user }

      it "redirects to the export page" do
        subject
        expect(response).to redirect_to(:settings_export)
      end
    end
  end
end
