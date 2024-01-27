# frozen_string_literal: true

require "rails_helper"

describe Moderation::InboxController do
  context "#index" do
    subject { get :index, params: params }

    let(:target_user) { FactoryBot.create(:user) }
    let!(:inboxes) { FactoryBot.create_list(:inbox_entry, 60, user: target_user) }
    let(:params) { { user: target_user.screen_name } }

    context "moderator signed in" do
      before do
        sign_in(FactoryBot.create(:user, roles: [:moderator]))
      end

      it "renders the index template" do
        subject
        expect(response).to render_template(:index)
      end

      it "assigns inbox entries" do
        subject
        expect(assigns(:inboxes).count).to eq(APP_CONFIG[:items_per_page])
      end
    end
  end
end
