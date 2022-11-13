# frozen_string_literal: true

require "rails_helper"
require "errors"
require "use_case/question/create"

describe UseCase::Question::Create do
  subject do
    UseCase::Question::Create.call(
      source_user_id:    source_user&.id,
      target_user_id:    target_user.id,
      content:           content,
      anonymous:         anonymous,
      author_identifier: author_identifier
    )
  end

  shared_examples "creates the question" do |should_send_to_inbox = true|
    it "creates the question" do
      expect { subject }.to change { Question.count }.by(1)
      question = Question.last
      expect(question.content).to eq(content)
      expect(question.author_is_anonymous).to eq(anonymous)
      expect(question.author_identifier).to eq(author_identifier)
      expect(question.direct).to eq(true)

      if should_send_to_inbox
        expect(target_user.inboxes.first.question_id).to eq(question.id)
      else
        expect(target_user.inboxes.first).to be_nil
      end
    end
  end

  shared_examples "invalid params" do
    it "raises an error" do
      expect { subject }.to raise_error(Errors::BadRequest)
    end
  end

  shared_examples "forbidden" do
    it "raises an error" do
      expect { subject }.to raise_error(Errors::Forbidden)
    end
  end

  shared_examples "not authorized" do
    it "raises an error" do
      expect { subject }.to raise_error(Errors::NotAuthorized)
    end
  end

  shared_examples "validates content" do
    context "content is empty" do
      let(:content) { "" }

      it "raises an error" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "content is too long" do
      let(:content) { "a" * 513 }

      it "raises an error" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  shared_examples "filters questions" do
    context "user blocks this anon" do
      before do
        target_user.anonymous_blocks.create!(
          identifier:  author_identifier,
          question_id: FactoryBot.create(:question).id
        )
      end

      it_behaves_like "creates the question", false
    end

    context "user mutes a term used in the question" do
      before { target_user.mute_rules.create!(muted_phrase: "hello") }

      it_behaves_like "creates the question", false
    end

    context "question is from an anon who is blocked globally" do
      before do
        AnonymousBlock.create!(
          identifier:  author_identifier,
          question_id: FactoryBot.create(:question).id,
          user_id:     nil
        )
      end

      it_behaves_like "creates the question", false
    end
  end

  context "user signed in" do
    let!(:source_user) { FactoryBot.create(:user) }

    context "target user exists" do
      let(:target_user) { FactoryBot.create(:user, privacy_allow_anonymous_questions: allow_anon) }
      let(:allow_anon) { true }

      context "content is not empty" do
        let(:content) { "Hello world" }

        context "question is anonymous" do
          let(:anonymous) { true }
          let(:author_identifier) { "abcdef" }

          context "recipient allows anonymous questions" do
            it_behaves_like "filters questions"
            it_behaves_like "creates the question"
            it_behaves_like "validates content"

            it "doesn't increment the source user's asked count" do
              expect { subject }.not_to(change { source_user.reload.asked_count })
            end
          end

          context "recipient does not allow anonymous questions" do
            let(:allow_anon) { false }

            it_behaves_like "forbidden"
          end
        end

        context "question is not anonymous" do
          let(:anonymous) { false }
          let(:author_identifier) { "qwerty" }

          it_behaves_like "creates the question"
          it_behaves_like "validates content"

          it "doesn't increment the source user's asked count" do
            expect { subject }.not_to(change { source_user.reload.asked_count })
          end
        end
      end
    end
  end

  context "user not signed in" do
    let!(:source_user) { nil }

    context "target user exists" do
      let(:target_user) { FactoryBot.create(:user, privacy_allow_anonymous_questions: allow_anon) }

      context "content is not empty" do
        let(:content) { "Hello world" }

        context "question is anonymous" do
          let(:anonymous) { true }
          let(:author_identifier) { "abcdef" }

          context "recipient allows anonymous questions" do
            let(:allow_anon) { true }

            it_behaves_like "filters questions"
            it_behaves_like "creates the question"
            it_behaves_like "validates content"
          end

          context "recipient does not allow anonymous questions" do
            let(:allow_anon) { false }

            it_behaves_like "forbidden"
          end
        end

        context "question is not anonymous" do
          let(:allow_anon) { true } # irrelevant for this test, but needs to be set
          let(:anonymous) { false }
          let(:author_identifier) { "qwerty" }

          it_behaves_like "invalid params"
        end
      end

      context "target user does not allow non-logged in questions" do
        let(:allow_anon) { true }
        let(:anonymous) { true }
        let(:content) { "Hello world" }
        let(:author_identifier) { "qwerty" }

        before do
          target_user.update!(privacy_require_user: true)
        end

        it_behaves_like "not authorized"
      end
    end
  end
end
