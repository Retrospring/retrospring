# frozen_string_literal: true

require "rails_helper"

describe Answer, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:question) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:smiles).dependent(:destroy) }
  end

  describe "after_create" do
    let(:user) { FactoryBot.create(:user) }
    let(:question_author) { FactoryBot.create(:user) }
    let(:question) { FactoryBot.create(:question, user: question_author, author_is_anonymous: false) }

    before do
      subject.content = "Answer text"
      subject.user = user
      subject.question = question
    end

    context "user has the question in their inbox" do
      before do
        Inbox.create(user:, question:, new: true)
      end

      it "should remove the question from the user's inbox" do
        expect { subject.save }.to change { user.inboxes.count }.by(-1)
      end
    end

    it "should notify the question's author" do
      expect { subject.save }.to change { question_author.notifications.count }.by(1)
    end

    it "should subscribe the answer's author to notifications for this answer" do
      expect { subject.save }.to change { user.subscriptions.count }.by(1)
      expect(user.subscriptions.first.answer).to eq(subject)
    end

    it "should subscribe the question's author to notifications for this answer" do
      expect { subject.save }.to change { question_author.subscriptions.count }.by(1)
    end

    it "should increment the user's answered_count" do
      expect { subject.save }.to change { user.answered_count }.by(1)
    end

    it "should increment the question's answer_count" do
      expect { subject.save }.to change { question.answer_count }.by(1)
    end
  end

  describe "before_destroy" do
    let(:user) { FactoryBot.create(:user) }
    let(:question_author) { FactoryBot.create(:user) }
    let(:question) { FactoryBot.create(:question, user: question_author, author_is_anonymous: false) }

    before do
      subject.content = "Answer text"
      subject.user = user
      subject.question = question
      subject.save
    end

    context "question author has a notification for the answer" do
      before do
        Notification.notify(question_author, subject)
      end

      it "should remove the answered notification from the question's author" do
        expect { subject.destroy }.to change { question_author.notifications.count }.by(-1)
      end
    end

    it "should unsubscribe the answer's author from notifications for this answer" do
      expect { subject.destroy }.to change { user.subscriptions.count }.by(-1)
    end

    it "should unsubscribe the question's author from notifications for this answer" do
      expect { subject.destroy }.to change { question_author.subscriptions.count }.by(-1)
    end

    it "should decrement the user's answered_count" do
      expect { subject.destroy }.to change { user.answered_count }.by(-1)
    end

    it "should decrement the question's answer_count" do
      expect { subject.destroy }.to change { question.answer_count }.by(-1)
    end
  end

  describe ".public_timeline" do
    let(:user) { FactoryBot.create(:user) }
    let(:user1) { FactoryBot.create(:user) }
    let(:user2) { FactoryBot.create(:user) }

    let(:blocked_user) { FactoryBot.create(:user) }
    let(:muted_user) { FactoryBot.create(:user) }
    let!(:answer_to_anonymous) do
      FactoryBot.create(
        :answer,
        user:     user1,
        content:  "answer to a true anonymous coward",
        question: FactoryBot.create(
          :question,
          author_is_anonymous: true
        )
      )
    end
    let!(:answer_to_normal_user) do
      FactoryBot.create(
        :answer,
        user:     user2,
        content:  "answer to a normal user",
        question: FactoryBot.create(
          :question,
          user:                user1,
          author_is_anonymous: false
        )
      )
    end
    let!(:answer_to_normal_user_anonymous) do
      FactoryBot.create(
        :answer,
        user:     user2,
        content:  "answer to a cowardly user",
        question: FactoryBot.create(
          :question,
          user:                user1,
          author_is_anonymous: true
        )
      )
    end
    let!(:answer_from_blocked_user) do
      FactoryBot.create(
        :answer,
        user:     blocked_user,
        content:  "answer from a blocked user",
        question: FactoryBot.create(:question)
      )
    end
    let!(:answer_to_blocked_user) do
      FactoryBot.create(
        :answer,
        user:     user1,
        content:  "answer to a blocked user",
        question: FactoryBot.create(
          :question,
          user:                blocked_user,
          author_is_anonymous: false
        )
      )
    end
    let!(:answer_to_blocked_user_anonymous) do
      FactoryBot.create(
        :answer,
        user:     user1,
        content:  "answer to a blocked user who's a coward",
        question: FactoryBot.create(
          :question,
          user:                blocked_user,
          author_is_anonymous: true
        )
      )
    end
    let!(:answer_from_muted_user) do
      FactoryBot.create(
        :answer,
        user:     muted_user,
        content:  "answer from a muted user",
        question: FactoryBot.create(:question)
      )
    end
    let!(:answer_to_muted_user) do
      FactoryBot.create(
        :answer,
        user:     user2,
        content:  "answer to a muted user",
        question: FactoryBot.create(
          :question,
          user:                muted_user,
          author_is_anonymous: false
        )
      )
    end
    let!(:answer_to_muted_user_anonymous) do
      FactoryBot.create(
        :answer,
        user:     user2,
        content:  "answer to a muted user who's a coward",
        question: FactoryBot.create(
          :question,
          user:                muted_user,
          author_is_anonymous: true
        )
      )
    end

    subject { Answer.public_timeline }

    it "includes all answers to questions from all the users" do
      expect(subject).to include(answer_to_anonymous)
      expect(subject).to include(answer_to_normal_user)
      expect(subject).to include(answer_to_normal_user_anonymous)
      expect(subject).to include(answer_to_blocked_user_anonymous)
      expect(subject).to include(answer_to_muted_user_anonymous)
      expect(subject).to include(answer_to_blocked_user)
      expect(subject).to include(answer_to_muted_user)
      expect(subject).to include(answer_from_blocked_user)
      expect(subject).to include(answer_from_muted_user)
    end

    context "when given a current user who blocks and mutes some users" do
      before do
        user.block blocked_user
        user.mute muted_user
      end

      subject { Answer.public_timeline current_user: user }

      it "only includes answers to questions from users the user doesn't block or mute" do
        expect(subject).to include(answer_to_anonymous)
        expect(subject).to include(answer_to_normal_user)
        expect(subject).to include(answer_to_normal_user_anonymous)
        expect(subject).to include(answer_to_blocked_user_anonymous)
        expect(subject).to include(answer_to_muted_user_anonymous)
        expect(subject).not_to include(answer_to_blocked_user)
        expect(subject).not_to include(answer_from_blocked_user)
        expect(subject).not_to include(answer_to_muted_user)
        expect(subject).not_to include(answer_from_muted_user)
      end
    end
  end
end
