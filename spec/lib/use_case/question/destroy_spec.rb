# frozen_string_literal: true

require "rails_helper"

describe UseCase::Question::Destroy do
  subject do
    UseCase::Question::Destroy.call(
      question_id:  question.id,
      current_user: current_user
    )
  end

  shared_examples "deletes the question" do
    it "deletes the question" do
      expect { subject }.to change { Question.count }.by(-1)
    end
  end

  context "question exists" do
    let!(:question) { FactoryBot.create(:question, user: question_owner) }

    context "user owns question" do
      let(:question_owner) { FactoryBot.create(:user) }
      let(:current_user) { question_owner }

      it_behaves_like "deletes the question"
    end

    context "user is a moderator" do
      let(:question_owner) { FactoryBot.create(:user) }
      let(:current_user) { FactoryBot.create(:user, roles: [:moderator]) }

      it_behaves_like "deletes the question"
    end

    context "user does not own question" do
      let(:question_owner) { FactoryBot.create(:user) }
      let(:current_user) { FactoryBot.create(:user) }

      it "raises an error" do
        expect { subject }.to raise_error(Errors::Forbidden)
      end
    end
  end
end
