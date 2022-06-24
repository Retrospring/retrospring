# frozen_string_literal: true

require "rails_helper"

describe ModerationController, type: :controller do
  describe "#toggle_unmask" do
    let(:user) { FactoryBot.create(:user, roles: [:moderator]) }

    before do
      sign_in(user)
      post :toggle_unmask, session: { moderation_view: moderation_view }
    end

    context "when moderation view flag is true" do
      let(:moderation_view) { true }

      it { is_expected.to set_session[:moderation_view].to(false) }

      it { is_expected.to redirect_to(root_path) }
    end

    context "when moderation view flag is false" do
      let(:moderation_view) { false }

      it { is_expected.to set_session[:moderation_view].to(true) }
    end

    context "when moderation view flag is not set" do
      let(:moderation_view) { nil }

      it { is_expected.to set_session[:moderation_view].to(true) }
    end
  end
end
