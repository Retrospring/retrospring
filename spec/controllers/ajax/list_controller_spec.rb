# frozen_string_literal: true

require "rails_helper"

describe Ajax::ListController, :ajax_controller, type: :controller do
  let(:target_user) { FactoryBot.create(:user) }

  describe "#create" do
    let(:name) { "I signori della gallassia" }
    let(:target_user_param) { target_user.screen_name }
    let(:params) do
      {
        "name" => name,
        "user" => target_user_param
      }
    end

    subject { post(:create, params: params) }

    context "when user is signed in" do
      let(:expected_response) do
        {
          "success" => true,
          "status" => "okay",
          "message" => anything,
          "render" => anything
        }
      end

      before(:each) { sign_in(user) }

      it "creates the list" do
        expect { subject }.to(change { user.lists.count }.by(1))
      end

      include_examples "returns the expected response"

      context "when name param is missing" do
        let(:name) { "" }
        let(:expected_response) do
          {
            "success" => false,
            "status" => "toolong",
            "message" => anything
          }
        end

        it "does not create the list" do
          expect { subject }.not_to(change { user.lists.count })
        end

        include_examples "returns the expected response"
      end

      context "when target user does not exist" do
        let(:target_user_param) { "giuseppe-drogo" }
        let(:expected_response) do
          {
            "success" => false,
            "status" => "notfound",
            "message" => anything
          }
        end

        it "does not create the list" do
          expect { subject }.not_to(change { user.lists.count })
        end

        include_examples "returns the expected response"
      end

      context "when list name is invalid for reasons" do
        let(:name) { "\u{1f43e}" }
        let(:expected_response) do
          {
            "success" => false,
            "status" => "toolong",
            "message" => anything
          }
        end

        it "does not create the list" do
          expect { subject }.not_to(change { user.lists.count })
        end

        include_examples "returns the expected response"
      end

      context "when list already exists" do
        before(:each) { post(:create, params: params) }
        let(:expected_response) do
          {
            "success" => false,
            "status" => "exists",
            "message" => anything
          }
        end

        it "does not create the list" do
          expect { subject }.not_to(change { user.lists.count })
        end

        include_examples "returns the expected response"
      end

      context "when someone else created a list with the same name" do
        before(:each) do
          FactoryBot.create(:list, user: target_user, display_name: name)
        end

        it "creates the list" do
          expect { subject }.to(change { user.lists.count }.by(1))
        end

        include_examples "returns the expected response"
      end
    end

    context "when user is not signed in" do
      let(:expected_response) do
        {
          "success" => false,
          "status" => "noauth",
          "message" => anything
        }
      end

      include_examples "returns the expected response"
    end
  end

  describe "#destroy" do
    let(:name) { "I signori della gallassia" }
    let(:list) { FactoryBot.create(:list, user: user, display_name: name) }
    let(:list_param) { list.name }
    let(:params) do
      {
        "list" => list_param
      }
    end

    subject { delete(:destroy, params: params) }

    context "when user is signed in" do
      let(:expected_response) do
        {
          "success" => true,
          "status" => "okay",
          "message" => anything
        }
      end

      before(:each) { sign_in(user) }

      it "deletes the list" do
        list
        expect { subject }.to(change { user.lists.count }.by(-1))
      end

      include_examples "returns the expected response"

      context "when list param is missing" do
        let(:list_param) { "" }
        let(:expected_response) do
          {
            "success" => false,
            "status" => "parameter_error",
            "message" => anything
          }
        end

        it "does not delete the list" do
          expect { subject }.not_to(change { user.lists.count })
        end

        include_examples "returns the expected response"
      end

      context "when list does not exist" do
        let(:list_param) { "the-foobars-and-the-dingdongs" }
        let(:expected_response) do
          {
            "success" => false,
            "status" => "err",
            "message" => anything
          }
        end

        it "does not delete the list" do
          expect { subject }.not_to(change { user.lists.count })
        end

        include_examples "returns the expected response"
      end

      context "when someone else created a list with the same name" do
        before(:each) do
          list
          FactoryBot.create(:list, user: target_user, display_name: name)
        end

        it "deletes the list" do
          expect { subject }.to(change { user.lists.count }.by(-1))
        end

        it "does not delete the other users' list" do
          expect { subject }.not_to(change { target_user.lists.count })
        end

        include_examples "returns the expected response"
      end
    end

    context "when user is not signed in" do
      let(:expected_response) do
        {
          "success" => false,
          "status" => "noauth",
          "message" => anything
        }
      end

      include_examples "returns the expected response"
    end
  end

  describe "#membership" do
    let(:name) { "The Agency" }
    let(:members) { [] }
    let(:list) { FactoryBot.create(:list, user: user, display_name: name, members: members) }
    let(:list_param) { list.name }
    let(:target_user_param) { target_user.screen_name }
    let(:params) do
      {
        "list" => list_param,
        "user" => target_user_param,
        "add" => add_param
      }
    end

    subject { post(:membership, params: params) }

    context "when user is signed in" do
      let(:expected_response) do
        {
          "success" => true,
          "status" => "okay",
          "message" => anything,
          "checked" => expected_checked
        }
      end

      before(:each) { sign_in(user) }

      context "when add is false" do
        let(:add_param) { "false" }
        let(:expected_checked) { false }

        it "does not do anything" do
          expect { subject }.not_to(change { list.members })
          expect(list.members.map { |gm| gm.user.id }.sort ).to eq([])
        end

        include_examples "returns the expected response"

        context "when the user was already added to the list" do
          let(:members) { [target_user] }

          it "removes the user from the list" do
            expect { subject }.to(change { list.reload.members.map { |gm| gm.user.id }.sort }.from([target_user.id]).to([]))
          end

          include_examples "returns the expected response"
        end
      end

      context "when add is true" do
        let(:add_param) { "true" }
        let(:expected_checked) { true }

        it "adds the user to the list" do
          expect { subject }.to(change { list.reload.members.map { |gm| gm.user.id }.sort }.from([]).to([target_user.id]))
        end

        include_examples "returns the expected response"

        context "when the user was already added to the list" do
          let(:members) { [target_user] }

          it "does not add the user to the list again" do
            expect { subject }.not_to(change { list.members })
            expect(list.members.map { |gm| gm.user.id }.sort ).to eq([target_user.id])
          end

          include_examples "returns the expected response"
        end
      end

      context "when list does not exist" do
        let(:list_param) { "the-good-agency" }
        let(:add_param) { "add" }
        let(:expected_response) do
          {
            "success" => false,
            "status" => "notfound",
            "message" => anything
          }
        end

        include_examples "returns the expected response"
      end

      context "when target user does not exist" do
        let(:target_user_param) { "erwin-proell" }
        let(:add_param) { "add" }
        let(:expected_response) do
          {
            "success" => false,
            "status" => "not_found",
            "message" => anything
          }
        end

        include_examples "returns the expected response"
      end
    end

    context "when user is not signed in" do
      let(:add_param) { "whatever" }
      let(:expected_response) do
        {
          "success" => false,
          "status" => "noauth",
          "message" => anything
        }
      end

      include_examples "returns the expected response"
    end
  end
end
