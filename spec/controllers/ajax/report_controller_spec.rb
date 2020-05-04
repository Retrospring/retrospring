# frozen_string_literal: true

require "rails_helper"

describe Ajax::ReportController, :ajax_controller, type: :controller do
  describe "#create" do
    let(:params) do
      {
        id: id,
        type: type,
        reason: reason
      }
    end
    subject { post(:create, params: params) }

    context "when user is signed in" do
      shared_examples "reporting an item" do |type|
        let(:type) { type }
        let(:id) { object.id }

        context "when #{type} exists" do
          before { object }

          context "when reason is empty" do
            let(:reason) { "" }

            it "creates a report of type Reports::#{type.capitalize}" do
              report_klass = "Reports::#{type.capitalize}".constantize
              expect { subject }.to(change { report_klass.count }.by(1))
              expect(report_klass.last.target).to eq(object)
              expect(report_klass.last.reason).to be_blank
            end

            include_examples "returns the expected response"
          end

          context "when reason is not empty" do
            let(:reason) { "I don't like this" }

            it "creates a report of type Reports::#{type.capitalize}" do
              report_klass = "Reports::#{type.capitalize}".constantize
              expect { subject }.to(change { report_klass.count }.by(1))
              expect(report_klass.last.target).to eq(object)
              expect(report_klass.last.reason).to eq(reason)
            end

            include_examples "returns the expected response"
          end
        end

        context "when #{type} does not exist" do
          let(:id) { "nonexistent" }
          let(:expected_response) do
            {
              "success" => false,
              "status" => "not_found",
              "message" => anything,
            }
          end

          context "when reason is empty" do
            let(:reason) { "" }

            it "does not create a report" do
              expect { subject }.not_to(change { Report.count })
            end

            include_examples "returns the expected response"
          end

          context "when reason is not empty" do
            let(:reason) { "I don't like this" }

            it "does not create a report" do
              expect { subject }.not_to(change { Report.count })
            end

            include_examples "returns the expected response"
          end
        end
      end

      let(:target_user) { FactoryBot.create(:user) }
      let(:expected_response) do
        {
          "success" => true,
          "status" => "okay",
          "message" => anything,
        }
      end

      before(:each) { sign_in(user) }

      it_behaves_like "reporting an item", "user" do
        let(:object) { target_user }
        let(:id) { object.screen_name }
      end

      it_behaves_like "reporting an item", "question" do
        let(:object) { FactoryBot.create(:question, user: target_user) }
      end

      it_behaves_like "reporting an item", "answer" do
        let(:object) { FactoryBot.create(:answer, user: target_user) }
      end

      it_behaves_like "reporting an item", "comment" do
        let(:answer) { FactoryBot.create(:answer, user: target_user) }
        let(:object) { FactoryBot.create(:comment, user: target_user, answer: answer) }
      end

      context "when type is anything else" do
        let(:id) { "whatever" }
        let(:type) { "whatever" }
        let(:reason) { "whatever" }
        let(:expected_response) do
          {
            "success" => false,
            "status" => "err",
            "message" => anything,
          }
        end

        it "does not create a report" do
          expect { subject }.not_to(change { Report.count })
        end

        include_examples "returns the expected response"
      end
    end

    context "when user is not signed in" do
      let(:id) { "peter_zwegat" }
      let(:type) { "user" }
      let(:reason) { "I'm broke now thanks to this bloke" }
      let(:expected_response) do
        {
          "success" => false,
          "status" => "err",
          "message" => anything
        }
      end

      it "does not create a report" do
        expect { subject }.not_to(change { Report.count })
      end

      include_examples "returns the expected response"
    end
  end
end
