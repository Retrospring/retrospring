# frozen_string_literal: true

require "rails_helper"

describe Subscription do
  describe "singleton object" do
    describe "#notify" do
      subject { Subscription.notify(source, target) }

      context "answer with one comment" do
        let(:answer_author) { FactoryBot.create(:user) }
        let(:answer) { FactoryBot.create(:answer, user: answer_author) }
        let(:commenter) { FactoryBot.create(:user) }
        let!(:comment) { FactoryBot.create(:comment, answer:, user: commenter) }
        let(:source) { comment }
        let(:target) { answer }

        it "notifies the target about source" do
          # The method we're testing here is already called the +after_create+ of +Comment+ so there already is a notification
          expect { subject }.to change { Notification.count }.from(1).to(2)
          created = Notification.order(:created_at).first!
          expect(created.target).to eq(comment)
          expect(created.recipient).to eq(answer_author)
        end
      end
    end
  end
end
