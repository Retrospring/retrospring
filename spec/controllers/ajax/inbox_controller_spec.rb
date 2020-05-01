# coding: utf-8
# frozen_string_literal: true

require "rails_helper"

describe Ajax::InboxController, :ajax_controller, type: :controller do
  describe "#create" do
    subject { post(:create) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      let(:expected_response) do
        {
          "success" => true,
          "status" => "okay",
          "message" => anything,
          "render" => anything
        }
      end

      it "creates a generated question to the user's inbox" do
        allow(QuestionGenerator).to receive(:generate).and_return("Is Mayonnaise an instrument?")
        expect { subject }.to(change { user.inboxes.count }.by(1))
        expect(user.inboxes.last.question.author_is_anonymous).to eq(true)
        expect(user.inboxes.last.question.author_name).to eq("justask")
        expect(user.inboxes.last.question.user).to eq(user)
        expect(user.inboxes.last.question.content).to eq("Is Mayonnaise an instrument?")
      end

      include_examples "returns the expected response"
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

  describe "#remove" do
    let(:params) do
      {
        id: inbox_entry_id
      }
    end

    subject { delete(:remove, params: params) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      context "when inbox entry exists" do
        let(:inbox_entry) { FactoryBot.create(:inbox, user: inbox_user) }
        let(:inbox_entry_id) { inbox_entry.id }

        # ensure the inbox entry exists
        before(:each) { inbox_entry }

        context "when inbox entry belongs to the current user" do
          let(:inbox_user) { user }
          let(:expected_response) do
            {
              "success" => true,
              "status" => "okay",
              "message" => anything
            }
          end

          it "removes the inbox entry" do
            expect { subject }.to(change { user.inboxes.count }.by(-1))
            expect { Inbox.find(inbox_entry.id) }.to raise_error(ActiveRecord::RecordNotFound)
          end

          include_examples "returns the expected response"
        end

        context "when inbox entry does not belong to the current user" do
          let(:inbox_user) { FactoryBot.create(:user) }
          let(:expected_response) do
            {
              "success" => false,
              "status" => "fail",
              "message" => anything
            }
          end

          it "does not remove the inbox entry" do
            expect { subject }.not_to(change { Inbox.count })
            expect { Inbox.find(inbox_entry.id) }.not_to raise_error
          end

          include_examples "returns the expected response"
        end
      end

      context "when inbox entry does not exist" do
        let(:inbox_entry_id) { "Nein!" }
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
      let(:inbox_entry_id) { "HACKED" }
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

  describe "#remove_all" do
    subject { delete(:remove_all) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      let(:expected_response) do
        {
          "success" => true,
          "status" => "okay",
          "message" => anything
        }
      end

      include_examples "returns the expected response"

      context "when user has some inbox entries" do
        let(:some_other_user) { FactoryBot.create(:user) }
        before do
          10.times { FactoryBot.create(:inbox, user: user) }
          10.times { FactoryBot.create(:inbox, user: some_other_user) }
        end

        it "deletes all the entries from the user's inbox" do
          expect { subject }.to(change { [Inbox.count, user.inboxes.count] }.from([20, 10]).to([10, 0]))
        end

        include_examples "returns the expected response"
      end
    end

    context "when user is not signed in" do
      let(:expected_response) do
        {
          "success" => false,
          "status" => "err",
          "message" => anything
        }
      end

      include_examples "returns the expected response"
    end
  end

  describe "#remove_all_author" do
    let(:params) do
      {
        author: author
      }
    end

    subject { delete(:remove_all_author, params: params) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }
      let(:author) { user.screen_name }

      let(:expected_response) do
        {
          "success" => true,
          "status" => "okay",
          "message" => anything
        }
      end

      include_examples "returns the expected response"

      context "when user has some inbox entries" do
        let(:some_other_user) { FactoryBot.create(:user) }
        let(:author) { some_other_user.screen_name }
        before do
          normal_question = FactoryBot.create(:question, user: some_other_user, author_is_anonymous: false)
          anon_question = FactoryBot.create(:question, user: some_other_user, author_is_anonymous: true)

          10.times { FactoryBot.create(:inbox, user: user) }
          3.times { FactoryBot.create(:inbox, user: user, question: normal_question) }
          2.times { FactoryBot.create(:inbox, user: user, question: anon_question) }
        end

        it "deletes all the entries asked by some other user which are not anonymous from the user's inbox" do
          expect { subject }.to(change { user.inboxes.count }.from(15).to(12))
        end

        include_examples "returns the expected response"
      end

      context "when author is unknown" do
        let(:author) { "schmarrn" }
        let(:expected_response) do
          {
            "success" => false,
            "status" => "err",
            "message" => anything
          }
        end

        include_examples "returns the expected response"
      end
    end

    context "when user is not signed in" do
      let(:author) { "hackerman1337" }
      let(:expected_response) do
        {
          "success" => false,
          "status" => "err",
          "message" => anything
        }
      end

      include_examples "returns the expected response"
    end
  end
end
