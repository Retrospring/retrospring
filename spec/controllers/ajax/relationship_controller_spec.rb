# coding: utf-8
# frozen_string_literal: true

require "rails_helper"

describe Ajax::RelationshipController, type: :controller do
  shared_examples_for "params is empty" do
    let(:params) { {} }

    include_examples "ajax does not succeed", "is required"
  end

  let!(:user) { FactoryBot.create(:user) }
  let!(:user2) { FactoryBot.create(:user) }

  describe "#create" do
    shared_examples_for "valid relationship type" do
      it_behaves_like "params is empty"

      context "target_user does not exist" do
        let(:target_user) { "peter-witzig" }

        include_examples "ajax does not succeed", "not found"
      end

      context "target_user is current user" do
        let(:target_user) { user.screen_name }

        include_examples "ajax does not succeed", "yourself"
      end

      context "target_user is different from current_user" do
        let(:target_user) { user2.screen_name }

        it "creates the relationship" do
          expect { subject }.to change { Relationship.count }.by(1)
          expect(Relationship.last.target.screen_name).to eq(target_user)
        end
      end
    end

    let(:type)        { "Sauerkraut" }
    let(:target_user) { user2.screen_name }
    let(:params)      { { type: type, target_user: target_user } }

    subject { post(:create, params: params) }

    it_behaves_like "requires login"

    context "user signed in" do
      before(:each) { sign_in(user) }

      context "type = 'follow'" do
        let(:type) { "follow" }

        include_examples "valid relationship type"
      end

      context "type = 'dick'" do
        let(:type) { "dick" }

        it_behaves_like "params is empty"
        include_examples "ajax does not succeed", "Invalid parameter"
      end
    end
  end

  describe "#destroy" do
    shared_examples_for "valid relationship type" do
      let(:target_user) { user2.screen_name }

      context "relationship exists" do
        before do
          user.public_send(type, user2)
        end

        it "destroys a relationship" do
          expect { subject }.to change { Relationship.count }.by(-1)
        end
      end

      context "relationship does not exist" do
        it "does not change anything at all" do
          expect { subject }.to change { Relationship.count }.by(0)
        end
      end

      context "target_user does not exist" do
        let(:target_user) { "peter-witzig" }

        include_examples "ajax does not succeed", "not found"
      end
    end

    let(:type)        { "Sauerkraut" }
    let(:target_user) { user2.screen_name }
    let(:params)      { { type: type, target_user: target_user } }

    subject { delete(:destroy, params: params) }

    it_behaves_like "requires login"

    context "user signed in" do
      before(:each) { sign_in(user) }

      context "type = 'follow'" do
        let(:type) { "follow" }

        include_examples "valid relationship type"
      end

      context "type = 'dick'" do
        let(:type) { "dick" }

        include_examples "ajax does not succeed", "Invalid parameter"
      end
    end
  end
end
