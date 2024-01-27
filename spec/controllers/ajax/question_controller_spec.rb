# frozen_string_literal: true

require "rails_helper"

describe Ajax::QuestionController, :ajax_controller, type: :controller do
  describe "#create" do
    shared_examples "creates the question" do |check_for_inbox = true|
      it "creates the question" do
        expect { subject }.to(change { Question.count }.by(1))
        expect(Question.last.content).to eq(question_content)
        expect(Question.last.author_is_anonymous).to be(expected_question_anonymous)
        expect(Question.last.user).to eq(expected_question_user)
      end

      if check_for_inbox
        it "adds the question to the target users' inbox" do
          expect { subject }.to(change { target_user.inbox_entries.count }.by(1))
          expect(target_user.inbox_entries.last.question.content).to eq(question_content)
        end
      end

      include_examples "returns the expected response"
    end

    shared_examples "does not create the question" do |check_for_inbox = true|
      it "does not create the question" do
        expect { subject }.not_to(change { Question.count })
      end

      if check_for_inbox
        it "does not add the question to the target users' inbox" do
          expect { subject }.not_to(change { target_user.inbox_entries.count })
        end
      end

      include_examples "returns the expected response"
    end

    shared_examples "creates the question but doesn't send it to the user's inbox" do
      it "creates the question" do
        expect { subject }.to(change { Question.count }.by(1))
      end

      it "does not add the question to the target users' inbox" do
        expect { subject }.not_to(change { target_user.inbox_entries.count })
      end

      include_examples "returns the expected response"
    end

    shared_examples "enqueues SendToInboxJob jobs" do
      it "enqueues a SendToInboxJob job" do
        allow(SendToInboxJob).to receive(:perform_bulk)
        subject
        question_id = Question.last.id
        bulk_args = followers.map { |f| [f.id, question_id] }
        expect(SendToInboxJob).to have_received(:perform_bulk).with(bulk_args)
      end

      include_examples "returns the expected response"
    end

    shared_examples "does not enqueue a SendToInboxJob job" do
      it "does not enqueue a SendToInboxJob job" do
        allow(SendToInboxJob).to receive(:perform_async)
        allow(SendToInboxJob).to receive(:perform_bulk)
        subject
        expect(SendToInboxJob).not_to have_received(:perform_async)
        expect(SendToInboxJob).not_to have_received(:perform_bulk)
      end

      include_examples "returns the expected response"
    end

    let(:target_user) { FactoryBot.create(:user, privacy_allow_anonymous_questions: user_allows_anonymous_questions) }
    let(:params) do
      {
        question:          question_content,
        anonymousQuestion: anonymous_question,
        rcpt:,
        sendToOwnInbox:    send_to_own_inbox,
      }
    end
    let(:send_to_own_inbox) { "false" }

    subject { post(:create, params: params) }

    context "when user is signed in" do
      let(:question_content) { "Was letzte Preis?" }
      let(:expected_response) do
        {
          "success" => true,
          "status"  => "okay",
          "message" => anything
        }
      end
      let(:expected_question_user) { user }

      before(:each) { sign_in(user) }

      context "when rcpt is a valid user" do
        let(:rcpt) { target_user.id }
        let(:send_to_own_inbox) { false }

        context "when user allows anonymous questions" do
          let(:user_allows_anonymous_questions) { true }

          context "when anonymousQuestion is true" do
            let(:anonymous_question) { "true" }
            let(:expected_question_anonymous) { true }

            include_examples "creates the question"
          end

          context "when anonymousQuestion is false" do
            let(:anonymous_question) { "false" }
            let(:expected_question_anonymous) { false }

            include_examples "creates the question"
          end
        end

        context "when user does not allow anonymous questions" do
          let(:user_allows_anonymous_questions) { false }

          context "when anonymousQuestion is true" do
            let(:anonymous_question) { "true" }
            let(:expected_response) do
              {
                "success" => false,
                "status"  => "forbidden",
                "message" => anything
              }
            end

            include_examples "does not create the question"
          end

          context "when anonymousQuestion is false" do
            let(:anonymous_question) { "false" }
            let(:expected_question_anonymous) { false }

            include_examples "creates the question"
          end
        end

        context "when the sender is blocked by the user" do
          before(:each) do
            target_user.block(user)
          end

          let(:anonymous_question) { "false" }
          let(:user_allows_anonymous_questions) { true }
          let(:expected_response) do
            {
              "message" => I18n.t("errors.asking_other_blocked_self"),
              "status"  => "asking_other_blocked_self",
              "success" => false
            }
          end

          include_examples "does not create the question", check_for_inbox: false
        end

        context "when the sender is muted by the user" do
          before(:each) do
            target_user.mute(user)
          end

          let(:anonymous_question) { "false" }
          let(:user_allows_anonymous_questions) { true }
          let(:expected_response) do
            {
              "success" => true,
              "status"  => "okay",
              "message" => anything
            }
          end

          include_examples "creates the question but doesn't send it to the user's inbox"
        end

        context "when the sender is blocking the user" do
          before(:each) do
            user.block(target_user)
          end

          let(:anonymous_question) { "false" }
          let(:user_allows_anonymous_questions) { true }
          let(:expected_response) do
            {
              "message" => I18n.t("errors.asking_self_blocked_other"),
              "status"  => "asking_self_blocked_other",
              "success" => false
            }
          end

          include_examples "does not create the question", check_for_inbox: false
        end
      end

      context "when rcpt is followers" do
        let(:rcpt) { "followers" }
        let(:followers) { FactoryBot.create_list(:user, 3) }

        before do
          followers.each { |follower| follower.follow(user) }
        end

        context "when anonymousQuestion is true" do
          let(:anonymous_question) { "true" }
          let(:expected_question_anonymous) { false }

          include_examples "creates the question", false
          include_examples "enqueues SendToInboxJob jobs"
        end

        context "when anonymousQuestion is false" do
          let(:anonymous_question) { "false" }
          let(:expected_question_anonymous) { false }

          include_examples "creates the question", false
          include_examples "enqueues SendToInboxJob jobs"
        end

        context "when sendToOwnInbox is true" do
          let(:anonymous_question) { "false" }
          let(:expected_question_anonymous) { false }
          let(:user_allows_anonymous_questions) { false }
          let(:send_to_own_inbox) { "true" }

          include_examples "creates the question", false

          it "sends question to the current user" do
            allow(SendToInboxJob).to receive(:perform_async)
            subject
            expect(SendToInboxJob).to have_received(:perform_async).with(user.id, Question.last.id)
          end
        end

        context "when sendToOwnInbox is false" do
          let(:anonymous_question) { "false" }
          let(:expected_question_anonymous) { false }
          let(:user_allows_anonymous_questions) { false }
          let(:send_to_own_inbox) { "false" }

          include_examples "creates the question", false

          it "sends question to the current user" do
            allow(SendToInboxJob).to receive(:perform_async)
            subject
            expect(SendToInboxJob).not_to have_received(:perform_async).with(user.id, Question.last.id)
          end
        end
      end

      context "when rcpt is an invalid value" do
        let(:rcpt) { "tripmeister_eder" }
        let(:send_to_own_inbox) { false }
        let(:anonymous_question) { "false" }
        let(:expected_response) do
          {
            "success" => false,
            "status"  => "err",
            "message" => "Invalid parameter"
          }
        end

        include_examples "does not create the question", false

        include_examples "returns the expected response"
      end

      context "when rcpt is a non-existent user" do
        let(:rcpt) { "-1" }
        let(:send_to_own_inbox) { false }
        let(:anonymous_question) { "false" }
        let(:expected_response) do
          {
            "success" => false,
            "status"  => "not_found",
            "message" => anything
          }
        end

        include_examples "does not create the question", false

        include_examples "returns the expected response"
      end
    end

    context "when user is not signed in" do
      let(:target_user) { FactoryBot.create(:user, privacy_allow_anonymous_questions: user_allows_anonymous_questions) }
      let(:question_content) { "Was letzte Preis?" }
      let(:anonymous_question) { "true" }
      let(:expected_response) do
        {
          "success" => true,
          "status"  => "okay",
          "message" => anything
        }
      end
      let(:expected_question_anonymous) { true }
      let(:expected_question_user) { nil }

      context "when rcpt is a valid user" do
        let(:rcpt) { target_user.id }

        context "when user allows anonymous questions" do
          let(:user_allows_anonymous_questions) { true }

          include_examples "creates the question"

          context "when anonymousQuestion is false" do
            let(:anonymous_question) { "false" }
            let(:expected_response) do
              {
                "success" => false,
                "status"  => "bad_request",
                "message" => anything
              }
            end

            include_examples "does not create the question"
          end

          context "when question contains a muted term" do
            before do
              MuteRule.create(user: target_user, muted_phrase: "Preis")
            end

            include_examples "creates the question but doesn't send it to the user's inbox"
          end

          context "when sender is blocked by the user" do
            before do
              identifier = AnonymousBlock.get_identifier("0.0.0.0")
              dummy_question = FactoryBot.create(:question, author_is_anonymous: true, author_identifier: identifier)
              AnonymousBlock.create(
                user:       target_user,
                identifier: identifier,
                question:   dummy_question
              )
            end

            include_examples "creates the question but doesn't send it to the user's inbox"
          end
        end

        context "when the sender is blocked by another user" do
          let(:user_allows_anonymous_questions) { true }
          let(:expected_question_user) { nil }
          let(:expected_question_direct) { true }

          before do
            identifier = AnonymousBlock.get_identifier("0.0.0.0")
            dummy_question = FactoryBot.create(:question, author_is_anonymous: true, author_identifier: identifier)
            AnonymousBlock.create(
              user:       FactoryBot.create(:user),
              identifier: identifier,
              question:   dummy_question
            )
          end

          include_examples "creates the question"
        end

        context "when user does not allow anonymous questions" do
          let(:user_allows_anonymous_questions) { false }
          let(:expected_response) do
            {
              "success" => false,
              "status"  => "forbidden",
              "message" => anything
            }
          end

          include_examples "does not create the question"

          context "when anonymousQuestion is false" do
            let(:anonymous_question) { "false" }
            let(:expected_response) do
              {
                "success" => false,
                "status"  => "bad_request",
                "message" => anything
              }
            end

            include_examples "does not create the question"
          end
        end

        context "when users inbox is locked" do
          let(:user_allows_anonymous_questions) { true }
          let(:expected_response) do
            {
              "success" => false,
              "status"  => "inbox_locked",
              "message" => anything
            }
          end

          before do
            target_user.update(privacy_lock_inbox: true)
          end

          include_examples "does not create the question"
        end
      end

      context "when rcpt is followers" do
        let(:rcpt) { "followers" }
        let(:expected_response) do
          {
            "success" => false,
            "status"  => "err",
            "message" => "Invalid parameter"
          }
        end

        include_examples "does not enqueue a SendToInboxJob job"
      end

      context "when rcpt is an invalid value" do
        let(:rcpt) { "tripmeister_eder" }
        let(:expected_response) do
          {
            "success" => false,
            "status"  => "err",
            "message" => "Invalid parameter"
          }
        end

        include_examples "does not create the question", false
      end

      context "when rcpt is a non-existent user" do
        let(:rcpt) { "-1" }
        let(:expected_response) do
          {
            "success" => false,
            "status"  => "not_found",
            "message" => anything
          }
        end

        include_examples "does not create the question", false
      end
    end
  end

  describe "#destroy" do
    shared_examples "does not delete the question" do |expected_status|
      let(:expected_response) do
        {
          "success" => false,
          "status"  => expected_status,
          "message" => anything
        }
      end

      it "does not delete the question" do
        question # ensure we already have it in the db
        expect { subject }.not_to(change { Question.count })
      end

      include_examples "returns the expected response"
    end

    let(:question_user) { user }
    let(:question) { FactoryBot.create(:question, user: question_user) }
    let(:question_id) { question.id }

    let(:params) do
      {
        question: question_id
      }
    end

    subject { delete(:destroy, params: params) }

    context "when user is signed in" do
      shared_examples "deletes the question" do
        let(:expected_response) do
          {
            "success" => true,
            "status"  => "okay",
            "message" => anything
          }
        end

        it "deletes the question" do
          question # ensure we already have it in the db
          expect { subject }.to(change { Question.count }.by(-1))
        end

        include_examples "returns the expected response"
      end

      before(:each) { sign_in(user) }

      context "when the question exists and was made by the current user" do
        include_examples "deletes the question"
      end

      context "when the question exists and was not made by the current user" do
        let(:question_user) { FactoryBot.create(:user) }

        include_examples "does not delete the question", "forbidden"

        %i[moderator administrator].each do |privileged_role|
          context "when the current user is a #{privileged_role}" do
            around do |example|
              user.add_role privileged_role
              example.run
              user.remove_role privileged_role
            end

            include_examples "deletes the question"
          end
        end
      end

      context "when the question exists and was not made by any registered user" do
        let(:question_user) { nil }

        include_examples "does not delete the question", "forbidden"

        %i[moderator administrator].each do |privileged_role|
          context "when the current user is a #{privileged_role}" do
            around do |example|
              user.add_role privileged_role
              example.run
              user.remove_role privileged_role
            end

            include_examples "deletes the question"
          end
        end
      end

      context "when the question does not exist" do
        let(:question_id) { "-1" }

        include_examples "does not delete the question", "not_found"
      end

      context "when the question is an invalid value" do
        let(:question_id) { "sonic_the_hedgehog" }

        # This case returns an invalid parameter error in the use case due to a type constraint
        include_examples "does not delete the question", "err"
      end
    end

    context "when user is not signed in" do
      # This case returns an invalid parameter error in the use case due to a type constraint
      include_examples "does not delete the question", "err"
    end
  end
end
