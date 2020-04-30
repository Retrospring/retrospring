# frozen_string_literal: true

require "rails_helper"

describe Ajax::FriendController, :ajax_controller, type: :controller do
  let(:user) { FactoryBot.create(:user) }

  describe "#create" do
    let(:params) do
      {
        screen_name: screen_name
      }
    end

    subject { post(:create, params: params) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      context "when target user exists" do
        let(:target_user) { FactoryBot.create(:user) }
        let(:screen_name) { target_user.screen_name }

        let(:expected_response) do
          {
            "success" => true,
            "status" => "okay",
            "message" => anything
          }
        end

        it "creates a follow relationship" do
          expect(user.friends.ids).not_to include(target_user.id)
          expect { subject }.to(change { user.friends.count }.by(1))
          expect(user.friends.ids).to include(target_user.id)
        end

        include_examples "returns the expected response"
      end

      context "when target user does not exist" do
        let(:screen_name) { "tripmeister_eder" }

        let(:expected_response) do
          {
            "success" => true,
            "status" => "okay",
            "message" => anything
          }
        end

        it "does not create a follow relationship" do
          expect { subject }.not_to(change { user.friends.count })
        end

        include_examples "returns the expected response"
      end
    end

    context "when user is not signed in" do
      let(:screen_name) { "tutenchamun" }
      let(:expected_response) do
        {
          "success" => false,
          "status" => "fail",
          "message" => anything
        }
      end

      include_examples "returns the expected response"
    end
  end

  describe "#destroy" do
    let(:params) do
      {
        screen_name: screen_name
      }
    end

    subject { delete(:destroy, params: params) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      context "when target user exists" do
        let(:target_user) { FactoryBot.create(:user) }
        let(:screen_name) { target_user.screen_name }

        before(:each) { target_user }

        context "when user follows target" do
          let(:expected_response) do
            {
              "success" => true,
              "status" => "okay",
              "message" => anything
            }
          end

          before(:each) { user.follow target_user }

          it "destroys a follow relationship" do
            expect(user.friends.ids).to include(target_user.id)
            expect { subject }.to(change { user.friends.count }.by(-1))
            expect(user.friends.ids).not_to include(target_user.id)
          end

          include_examples "returns the expected response"
        end

        context "when user does not already follow target" do
          let(:expected_response) do
            {
              "success" => false,
              "status" => "fail",
              "message" => anything
            }
          end

          it "does not destroy a follow relationship" do
            expect { subject }.not_to(change { user.friends.count })
          end

          include_examples "returns the expected response"
        end
      end

      context "when target user does not exist" do
        let(:screen_name) { "tripmeister_eder" }

        let(:expected_response) do
          {
            "success" => false,
            "status" => "fail",
            "message" => anything
          }
        end

        it "does not destroy a follow relationship" do
          expect { subject }.not_to(change { user.friends.count })
        end

        include_examples "returns the expected response"
      end
    end

    context "when user is not signed in" do
      let(:screen_name) { "tutenchamun" }
      let(:expected_response) do
        {
          "success" => false,
          "status" => "fail",
          "message" => anything
        }
      end

      include_examples "returns the expected response"
    end
  end
end
