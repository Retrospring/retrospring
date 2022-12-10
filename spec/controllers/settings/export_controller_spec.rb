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

      context "when user has a new DataExported notification" do
        let(:notification) do
          Notification::DataExported.create(
            target_id:   user.id,
            target_type: "User::DataExport",
            recipient:   user,
            new:         true
          )
        end

        it "marks the notification as read" do
          expect { subject }.to change { notification.reload.new }.from(true).to(false)
        end
      end
    end
  end

  describe "#create" do
    subject { post :create }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before { sign_in user }

      it "enqueues an ExportWorker job" do
        subject
        expect(ExportWorker).to have_enqueued_sidekiq_job(user.id)
      end

      it "redirects to the export page" do
        subject
        expect(response).to redirect_to(:settings_export)
      end
    end
  end
end
