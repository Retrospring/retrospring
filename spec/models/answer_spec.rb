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
        Inbox.create(user: user, question: question, new: true)
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
end
