# frozen_string_literal: true

require "rails_helper"

describe UseCase::Answer::Unpin do
  include ActiveSupport::Testing::TimeHelpers

  subject { UseCase::Answer::Unpin.call(user:, answer:) }

  context "answer exists" do
    let(:pinned_at) { Time.at(1603290950).utc }
    let(:answer) { FactoryBot.create(:answer, user: FactoryBot.create(:user), pinned_at:) }

    context "as answer owner" do
      let(:user) { answer.user }

      it "unpins the answer" do
        expect { subject }.to change { answer.pinned_at }.from(pinned_at).to(nil)
      end

      context "answer is already unpinned" do
        let(:pinned_at) { nil }

        it "raises an error" do
          expect { subject }.to raise_error(Errors::BadRequest)
          expect(answer.reload.pinned_at).to eq(nil)
        end
      end
    end

    context "as other user" do
      let(:user) { FactoryBot.create(:user) }

      it "does not unpin the answer" do
        expect { subject }.to raise_error(Errors::NotAuthorized)
        expect(answer.reload.pinned_at).to eq(pinned_at)
      end
    end
  end
end
