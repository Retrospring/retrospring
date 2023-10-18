# frozen_string_literal: true

require "rails_helper"

describe Inbox, type: :model do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:question) }
  end

  describe "before_destroy" do
    let(:user) { FactoryBot.create(:user) }
    let(:question) { FactoryBot.create(:question, author_is_anonymous: true) }

    it "does not fail if the user wants to delete their account" do
      Inbox.create(user:, question:)

      # this deletes the User record and enqueues the deletion of all
      # associated records in sidekiq
      user.destroy!

      # so let's drain the queues
      expect { Sidekiq::Worker.drain_all }.not_to raise_error
    end
  end
end
