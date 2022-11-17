# frozen_string_literal: true

require "rails_helper"

describe InboxController, type: :controller do
  let(:user) { FactoryBot.create(:user) }

  describe "#show" do
    subject { get :show }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      it "shows the inbox" do
        subject
        expect(response).to render_template("show")
      end
    end
  end

  describe "#create" do
    subject { post :create }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      it "creates an inbox entry" do
        expect { subject }.to(change { user.inboxes.count }.by(1))
      end
    end
  end
end
