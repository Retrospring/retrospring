# frozen_string_literal: true

require "rails_helper"

describe Ajax::WebPushController, :ajax_controller, type: :controller do
  before do
    Rpush::Webpush::App.create(
      name:        "webpush",
      certificate: { public_key: "AAAA", private_key: "BBBB", subject: "" }.to_json,
      connections: 1
    )
  end

  describe "#key" do
    subject { get :key, format: :json }

    let(:expected_response) do
      {
        "message" => "",
        "status"  => "okay",
        "success" => true,
        "key"     => "AAAA"
      }
    end

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before { sign_in user }

      include_examples "returns the expected response"
    end
  end

  describe "#subscribe" do
    subject { post :subscribe, params: }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before { sign_in user }

      context "given a valid subscription" do
        let(:params) do
          {
            subscription: {
              endpoint: "https://some.webpush/endpoint",
              keys:     {}
            }
          }
        end
        let(:expected_response) do
          {
            "message" => I18n.t("settings.push_notifications.subscription_count.one"),
            "status"  => "okay",
            "success" => true
          }
        end

        it "stores the subscription" do
          expect { subject }
            .to(
              change { WebPushSubscription.count }
                .by(1)
            )
        end

        include_examples "returns the expected response"
      end
    end

    context "given no subscription param" do
      let(:params) do
        {}
      end
    end
  end

  describe "#unsubscribe" do
    subject { delete :unsubscribe, params: }

    shared_examples_for "does not remove any subscriptions" do
      it "does not remove any subscriptions" do
        expect { subject }.not_to(change { WebPushSubscription.count })
      end
    end

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before { sign_in user }

      context "valid subscription" do
        let(:endpoint) { "some endpoint" }
        let!(:subscription) do
          WebPushSubscription.create(
            user:,
            subscription: { endpoint:, keys: {} }
          )
        end
        let!(:other_subscription) do
          WebPushSubscription.create(
            user:,
            subscription: { endpoint: "other endpoint", keys: {} }
          )
        end
        let(:params) do
          { endpoint: }
        end
        let(:expected_response) do
          {
            "status"  => "okay",
            "success" => true,
            "message" => I18n.t("ajax.web_push.subscription_count.one"),
            "count"   => 1
          }
        end

        it "removes the subscription" do
          subject
          expect(WebPushSubscription.exists?(subscription.id)).to eq(false)
          expect(WebPushSubscription.exists?(other_subscription.id)).to eq(true)
        end

        include_examples "returns the expected response"
      end

      context "invalid subscription" do
        let!(:subscription) do
          WebPushSubscription.create(
            user:,
            subscription: { endpoint: "other endpoint", keys: {} }
          )
        end
        let(:params) do
          { endpoint: "some endpoint" }
        end
        let(:expected_response) do
          {
            "status"  => "err",
            "success" => false,
            "message" => I18n.t("ajax.web_push.subscription_count.one"),
            "count"   => 1
          }
        end

        include_examples "does not remove any subscriptions"
        include_examples "returns the expected response"
      end

      context "someone else's subscription" do
        let(:endpoint) { "some endpoint" }
        let(:other_user) { FactoryBot.create(:user) }
        let!(:subscription) do
          WebPushSubscription.create(
            user:         other_user,
            subscription: { endpoint:, keys: {} }
          )
        end
        let(:params) do
          { endpoint: }
        end
        let(:expected_response) do
          {
            "status"  => "err",
            "success" => false,
            "message" => I18n.t("ajax.web_push.subscription_count.zero"),
            "count"   => 0
          }
        end

        include_examples "does not remove any subscriptions"
        include_examples "returns the expected response"
      end

      context "no subscription provided" do
        let(:other_user) { FactoryBot.create(:user) }
        let(:params) { {} }

        before do
          4.times do |i|
            WebPushSubscription.create(
              user:         i.zero? ? other_user : user,
              subscription: { endpoint: i, keys: {} }
            )
          end
        end

        it "removes all own subscriptions" do
          expect { subject }
            .to(
              change { WebPushSubscription.count }
                .from(4)
                .to(1)
            )
        end
      end
    end
  end

  describe "#check" do
    subject { post :check, params: }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }
      let(:endpoint) { "https://some.domain/some/webpush/endpoint" }
      let!(:subscription) do
        WebPushSubscription.create(
          user:,
          subscription: { endpoint:, keys: {} },
          failures:
        )
      end
      let(:expected_response) do
        {
          "message" => "",
          "status"  => expected_status,
          "success" => true
        }
      end

      before { sign_in user }

      context "subscription exists" do
        let(:params) do
          { endpoint: }
        end

        context "without failures" do
          let(:failures) { 0 }
          let(:expected_status) { "subscribed" }

          it_behaves_like "returns the expected response"
        end

        context "with 2 failures" do
          let(:failures) { 2 }
          let(:expected_status) { "subscribed" }

          it_behaves_like "returns the expected response"
        end

        context "with 3 failures" do
          let(:failures) { 3 }
          let(:expected_status) { "failed" }

          it_behaves_like "returns the expected response"
        end
      end

      context "subscription doesn't exist" do
        let(:params) do
          { endpoint: "https;//some.domain/some/other/endpoint" }
        end

        let(:failures) { 0 }
        let(:expected_status) { "unsubscribed" }

        it_behaves_like "returns the expected response"
      end
    end
  end
end
