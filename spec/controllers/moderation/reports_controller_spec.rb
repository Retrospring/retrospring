# frozen_string_literal: true

require "rails_helper"

describe Moderation::ReportsController, type: :controller do
  let(:user) { FactoryBot.create :user, roles: ["moderator"] }

  describe "#index" do
    shared_examples_for "sets the expected ivars" do
      let(:expected_assigns) { {} }

      it "sets the expected ivars" do
        subject

        expected_assigns.each do |name, value|
          expect(assigns[name]).to eq(value)
        end
      end
    end

    context "template rendering" do
      let(:other_user) { FactoryBot.create :user }
      let(:report) { Report.create(user:, target_id: other_user.id, type: "Reports::User") }

      subject { get :index }

      before do
        report
        sign_in user
      end

      it "renders the moderation/reports/index template" do
        subject
        expect(response).to render_template("moderation/reports/index")
      end

      include_examples "sets the expected ivars" do
        let(:expected_assigns) do
          {
            reports:         [report],
            reports_last_id: report.id,
          }
        end
      end
    end

    context "filtering for target users" do
      let(:other_user) { FactoryBot.create :user }
      let(:question) { FactoryBot.create :question }
      let(:report) { Report.create(user:, target_id: other_user.id, target_user_id: other_user.id, type: "Reports::User") }
      let(:report2) { Report.create(user:, target_id: question.id, target_user_id: nil, type: "Reports::Question") }

      subject { get :index, params: { target_user: other_user.screen_name } }

      before do
        report
        report2
        sign_in user
      end

      include_examples "sets the expected ivars" do
        let(:expected_assigns) do
          {
            reports:         [report],
            reports_last_id: report.id,
          }
        end
      end
    end

    context "filtering for users" do
      let(:report_user) { FactoryBot.create :user }
      let(:other_user) { FactoryBot.create :user }
      let(:question) { FactoryBot.create :question }
      let(:report) { Report.create(user:, target_id: other_user.id, target_user_id: other_user.id, type: "Reports::User") }
      let(:report2) { Report.create(user: report_user, target_id: question.id, target_user_id: nil, type: "Reports::Question") }

      subject { get :index, params: { user: report_user.screen_name } }

      before do
        report
        report2
        sign_in user
      end

      include_examples "sets the expected ivars" do
        let(:expected_assigns) do
          {
            reports:         [report2],
            reports_last_id: report2.id,
          }
        end
      end
    end

    context "filtering for type" do
      let(:report_user) { FactoryBot.create :user }
      let(:other_user) { FactoryBot.create :user }
      let(:question) { FactoryBot.create :question }
      let(:report) { Report.create(user:, target_id: other_user.id, target_user_id: other_user.id, type: "Reports::User") }
      let(:report2) { Report.create(user: report_user, target_id: question.id, target_user_id: nil, type: "Reports::Question") }

      subject { get :index, params: { type: "question" } }

      before do
        report
        report2
        sign_in user
      end

      include_examples "sets the expected ivars" do
        let(:expected_assigns) do
          {
            reports:         [report2],
            reports_last_id: report2.id,
          }
        end
      end
    end
  end
end
