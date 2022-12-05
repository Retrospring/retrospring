# frozen_string_literal: true

require "rails_helper"

describe ListsController, :ajax_controller, type: :controller do
  let(:target_user) { FactoryBot.create(:user) }
  let(:user) { FactoryBot.create(:user) }

  describe "#create" do
    let(:params) do
      {
        user: target_user.screen_name,
        name: Faker::Lorem.sentence
      }
    end

    subject { post(:create, params:) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      it "creates a new list" do
        expect { subject }.to(change { List.count }.by(1))
      end
    end
  end

  describe "#destroy" do
    let(:list) { FactoryBot.create(:list, user:) }
    let(:params) do
      {
        list: list.id
      }
    end

    subject { delete(:destroy, params:) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      context "when list exists" do
        before(:each) { list }

        it "removes the list" do
          expect { subject }.to(change { List.count }.by(-1))
        end
      end
    end
  end

  describe "#update" do
    let(:list) { FactoryBot.create(:list, user:) }

    subject { put(:update, params:) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      context "add user to list" do
        let(:params) do
          {
            list: list.id,
            user: target_user.screen_name,
            add:  true
          }
        end

        it "adds a list member to the list" do
          expect { subject }.to(change { list.list_members.count }.by(1))
        end
      end

      context "remove user from list" do
        let(:params) do
          {
            list: list.id,
            user: target_user.screen_name,
            add:  false
          }
        end

        before(:each) do
          list.list_members.create(user: target_user)
        end

        it "removes a list member from the list" do
          expect { subject }.to(change { list.list_members.count }.by(-1))
        end
      end
    end
  end
end
