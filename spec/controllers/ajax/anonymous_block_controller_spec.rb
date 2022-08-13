# frozen_string_literal: true

require "rails_helper"

describe Ajax::AnonymousBlockController, :ajax_controller, type: :controller do
  describe "#create" do
    subject { post(:create, params: params) }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in(user)
      end

      context "when all required parameters are given" do
        let(:question) { FactoryBot.create(:question, author_identifier: "someidentifier") }
        let!(:inbox) { FactoryBot.create(:inbox, user:, question:) }
        let(:params) do
          { question: question.id }
        end

        let(:expected_response) do
          {
            "success" => true,
            "status"  => "okay",
            "message" => anything
          }
        end

        it "creates an anonymous block" do
          expect { subject }.to(change { AnonymousBlock.count }.by(1))
        end

        include_examples "returns the expected response"
      end

      context "when blocking a user globally" do
        let(:question) { FactoryBot.create(:question, author_identifier: "someidentifier") }
        let!(:inbox) { FactoryBot.create(:inbox, user:, question:) }
        let(:params) do
          { question: question.id, global: "true" }
        end

        context "as a moderator" do
          let(:expected_response) do
            {
              "success" => true,
              "status"  => "okay",
              "message" => anything
            }
          end

          before do
            user.add_role(:moderator)
          end

          it "creates an site-wide anonymous block" do
            expect { subject }.to(change { AnonymousBlock.count }.by(1))
            expect(AnonymousBlock.last.user_id).to be_nil
          end

          include_examples "returns the expected response"
        end

        context "as a regular user" do
          let(:expected_response) do
            {
              "success" => false,
              "status"  => "forbidden",
              "message" => anything
            }
          end

          it "does not create an anonymous block" do
            expect { subject }.not_to(change { AnonymousBlock.count })
          end

          include_examples "returns the expected response"
        end
      end

      context "when parameters are missing" do
        let(:params) { {} }
        let(:expected_response) do
          {
            "success" => false,
            "status"  => "parameter_error",
            "message" => anything
          }
        end

        it "does not create an anonymous block" do
          expect { subject }.not_to(change { AnonymousBlock.count })
        end

        include_examples "returns the expected response"
      end
    end
  end

  describe "#destroy" do
    subject { delete(:destroy, params: params) }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in(user)
      end

      context "when all parameters are given" do
        let(:question) { FactoryBot.create(:question, author_identifier: "someidentifier") }
        let(:block) { AnonymousBlock.create(user: user, identifier: "someidentifier", question: question) }
        let(:params) do
          { id: block.id }
        end

        let(:expected_response) do
          {
            "success" => true,
            "status"  => "okay",
            "message" => anything
          }
        end

        include_examples "returns the expected response"
      end
    end
  end
end
