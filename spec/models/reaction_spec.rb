# frozen_string_literal: true

require "rails_helper"

describe Reaction do
  let(:user) { FactoryBot.create(:user) }
  let(:owner) { FactoryBot.create(:user) }
  let(:parent) { FactoryBot.create(:answer, user: owner) }

  before do
    subject.content = "🙂"
    subject.parent = parent
    subject.user = user
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:parent) }
  end

  describe "after_create" do
    context "owner is subscribed to the parent" do
      before do
        Subscription.subscribe(owner, parent)
      end

      it "should notify the parent's author" do
        expect { subject.save }.to change { owner.notifications.count }.by(1)
      end
    end

    it "should increment the user's smiled count" do
      expect { subject.save }.to change { user.smiled_count }.by(1)
    end

    it "should increment the parent's smiled count" do
      expect { subject.save }.to change { parent.smile_count }.by(1)
    end
  end

  describe "before_destroy" do
    context "owner has a notification for this reaction" do
      before do
        subject.save
        Notification.notify(owner, subject)
      end

      it "should denotify the parent's author" do
        expect { subject.destroy }.to change { owner.notifications.count }.by(-1)
      end
    end

    it "should reduce the user's smiled count" do
      expect { subject.destroy }.to change { user.smiled_count }.by(-1)
    end

    it "should reduce the parent's smiled count" do
      expect { subject.destroy }.to change { parent.smile_count }.by(-1)
    end
  end
end
