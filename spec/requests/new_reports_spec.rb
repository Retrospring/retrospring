# frozen_string_literal: true

require "rails_helper"

RSpec.describe "New reports indicator", type: :request do
  let(:user) { FactoryBot.create(:user, roles: [:moderator]) }

  before do
    sign_in user
  end

  subject { get "/" }

  describe "setting an assign for new reports" do
    context "never visited the reports listing before" do
      it "sets a assign" do
        subject

        expect(assigns["has_new_reports"]).to eq(true)
      end
    end

    context "visited the reports listing, with no new reports" do
      before do
        user.last_reports_visit = DateTime.now
        user.save
      end

      it "sets a assign" do
        subject

        expect(assigns["has_new_reports"]).to eq(false)
      end
    end

    context "visited the reports listing, with new reports" do
      let(:other_user) { FactoryBot.create :user }

      before do
        Report.create(user:, target_id: other_user.id, target_user_id: other_user.id, type: "Reports::User", created_at: DateTime.now)
        user.last_reports_visit = DateTime.now - 1.day
        user.save
      end

      it "sets a assign" do
        subject

        expect(assigns["has_new_reports"]).to eq(true)
      end
    end
  end
end
