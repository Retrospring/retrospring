# frozen_string_literal: true

require "rails_helper"

describe SubscriptionsController, type: :controller do
  # need to use a different user here, as after a create the user owning the
  # answer is automatically subscribed to it
  let(:answer_user) { FactoryBot.create(:user) }
  let(:answer) { FactoryBot.create(:answer, user: answer_user) }
  let(:user) { FactoryBot.create(:user) }

  describe "#create" do
    let(:params) do
      {
        answer: answer_id,
      }
    end

    subject { post(:create, params:, format: :turbo_stream) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      context "when answer exists" do
        let(:answer_id) { answer.id }

        context "when subscription does not exist" do
          it "creates a subscription on the answer" do
            expect { subject }.to(change { answer.subscriptions.count }.by(1))
            expect(answer.subscriptions.map { |s| s.user.id }.sort).to eq([answer_user.id, user.id].sort)
          end
        end

        context "when subscription already exists" do
          before(:each) { Subscription.subscribe(user, answer) }

          it "does not modify the answer's subscriptions" do
            expect { subject }.to(change { answer.subscriptions.count }.by(0))
            expect(answer.subscriptions.map { |s| s.user.id }.sort).to eq([answer_user.id, user.id].sort)
          end
        end
      end

      context "when answer does not exist" do
        let(:answer_id) { "Bielefeld" }

        it "does not create a new subscription" do
          expect { subject }.not_to(change { Subscription.count })
        end
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

  describe "#destroy" do
    let(:params) do
      {
        answer: answer_id,
      }
    end

    subject { delete(:destroy, params:, format: :turbo_stream) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      context "when answer exists" do
        let(:answer_id) { answer.id }

        context "when subscription exists" do
          before(:each) { Subscription.subscribe(user, answer) }

          it "removes an active subscription from the answer" do
            expect { subject }.to(change { answer.subscriptions.count }.by(-1))
            expect(answer.subscriptions.map { |s| s.user.id }.sort).to eq([answer_user.id].sort)
          end
        end

        context "when subscription does not exist" do
          it "does not modify the answer's subscriptions" do
            expect { subject }.to(change { answer.subscriptions.count }.by(0))
            expect(answer.subscriptions.map { |s| s.user.id }.sort).to eq([answer_user.id].sort)
          end
        end
      end

      context "when answer does not exist" do
        let(:answer_id) { "Bielefeld" }

        it "does not create a new subscription" do
          expect { subject }.not_to(change { Subscription.count })
        end
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
