# frozen_string_literal: true

require "rails_helper"

describe Notification, type: :model do
  describe "associations" do
    it { should belong_to(:recipient) }
    it { should belong_to(:target) }
  end

  describe "before_destroy" do
    let(:user) { FactoryBot.create(:user) }
    let(:answer) { FactoryBot.create(:answer, user: FactoryBot.create(:user)) }

    it "does not fail if the user wants to delete their account" do
      Notification::QuestionAnswered.create(recipient: user, target: answer)

      # this deletes the User record and enqueues the deletion of all
      # associated records in sidekiq
      user.destroy!

      # so let's drain the queues
      expect { Sidekiq::Worker.drain_all }.not_to raise_error
    end
  end
end
