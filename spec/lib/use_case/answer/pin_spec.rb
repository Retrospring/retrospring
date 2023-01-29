# frozen_string_literal: true

require "rails_helper"

describe UseCase::Answer::Pin do
  include ActiveSupport::Testing::TimeHelpers

  subject { UseCase::Answer::Pin.call(user:, answer:) }

  context "answer exists" do
    let(:answer) { FactoryBot.create(:answer, user: FactoryBot.create(:user)) }

    context "as answer owner" do
      let(:user) { answer.user }

      it "pins the answer" do
        travel_to(Time.at(1603290950).utc) do
          expect { subject }.to change { answer.pinned_at }.from(nil).to(Time.at(1603290950).utc)
        end
      end
    end

    context "as other user" do
      let(:user) { FactoryBot.create(:user) }

      it "does not pin the answer" do
        expect { subject }.to raise_error(Errors::NotAuthorized)
        expect(answer.reload.pinned_at).to eq(nil)
      end
    end
  end
end
