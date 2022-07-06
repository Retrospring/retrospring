# frozen_string_literal: true

require "rails_helper"

describe Ajax::SubscriptionController, :ajax_controller, type: :controller do
  # need to use a different user here, as after a create the user owning the
  # answer is automatically subscribed to it
  let(:answer_user) { FactoryBot.create(:user) }
  let(:answer) { FactoryBot.create(:answer, user: answer_user) }

  describe "#subscribe" do
    let(:params) do
      {
        answer: answer_id
      }
    end

    subject { post(:subscribe, params: params) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      context "when answer exists" do
        let(:answer_id) { answer.id }
        let(:expected_response) do
          {
            "success" => true,
            "status" =>  "okay",
            "message" => anything
          }
        end

        context "when subscription does not exist" do
          it "creates a subscription on the answer" do
            expect { subject }.to(change { answer.subscriptions.count }.by(1))
            expect(answer.subscriptions.where(is_active: true).map { |s| s.user.id }.sort).to eq([answer_user.id, user.id].sort)
          end

          include_examples "returns the expected response"
        end

        context "when subscription already exists" do
          before(:each) { Subscription.subscribe(user, answer) }

          it "does not modify the answer's subscriptions" do
            expect { subject }.to(change { answer.subscriptions.count }.by(0))
            expect(answer.subscriptions.where(is_active: true).map { |s| s.user.id }.sort).to eq([answer_user.id, user.id].sort)
          end

          include_examples "returns the expected response"
        end
      end

      context "when answer does not exist" do
        let(:answer_id) { "Bielefeld" }
        let(:expected_response) do
          {
            "success" => false,
            "status" => "not_found",
            "message" => anything
          }
        end

        it "does not create a new subscription" do
          expect { subject }.not_to(change { Subscription.count })
        end

        include_examples "returns the expected response"
      end
    end

    context "when user is not signed in" do
      let(:answer_id) { answer.id }

      it "redirects to somewhere else, apparently" do
        subject
        expect(response).to be_a_redirect
      end
    end
  end

  describe "#unsubscribe" do
    let(:params) do
      {
        answer: answer_id
      }
    end

    subject { post(:unsubscribe, params: params) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      context "when answer exists" do
        let(:answer_id) { answer.id }
        let(:expected_response) do
          {
            "success" => true,
            "status" =>  "okay",
            "message" => anything
          }
        end

        context "when subscription exists" do
          before(:each) { Subscription.subscribe(user, answer) }

          it "removes an active subscription from the answer" do
            expect { subject }.to(change { answer.subscriptions.where(is_active: true).count }.by(-1))
            expect(answer.subscriptions.where(is_active: true).map { |s| s.user.id }.sort).to eq([answer_user.id].sort)
          end

          include_examples "returns the expected response"
        end

        context "when subscription does not exist" do
          let(:expected_response) do
            {
              "success" => false,
              "status" =>  "okay",
              "message" => anything
            }
          end

          it "does not modify the answer's subscriptions" do
            expect { subject }.to(change { answer.subscriptions.count }.by(0))
            expect(answer.subscriptions.where(is_active: true).map { |s| s.user.id }.sort).to eq([answer_user.id].sort)
          end

          include_examples "returns the expected response"
        end
      end

      context "when answer does not exist" do
        let(:answer_id) { "Bielefeld" }
        let(:expected_response) do
          {
            "success" => false,
            "status" => "not_found",
            "message" => anything
          }
        end

        it "does not create a new subscription" do
          expect { subject }.not_to(change { Subscription.count })
        end

        include_examples "returns the expected response"
      end
    end

    context "when user is not signed in" do
      let(:answer_id) { answer.id }

      it "redirects to somewhere else, apparently" do
        subject
        expect(response).to be_a_redirect
      end
    end
  end
end
