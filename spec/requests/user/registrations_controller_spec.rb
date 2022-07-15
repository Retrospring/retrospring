# frozen_string_literal: true

require "rails_helper"

RSpec.describe User::RegistrationsController, type: :controller do
  let(:user) { FactoryBot.create(:user, **user_params) }

  describe "DELETE #destroy" do
    subject { delete :destroy }

    context "user has an export pending" do
      let(:user_params) { { export_processing: true } }

      before do
        @request.env["devise.mapping"] = Devise.mappings[:user] # so that devise knows that we're testing the user controller
        sign_in(user)
      end

      it "doesn't allow for the account to be deleted" do
        subject
        expect(flash[:error]).to eq(I18n.t("user.registrations.destroy.export_pending"))
      end
    end
  end
end
