# frozen_string_literal: true

require "rails_helper"

RSpec.describe Question, type: :model do
  let(:user) { FactoryBot.create :user }

  let(:question) { Question.new(content: "Is this a question?", user:) }

  subject { question }

  it { is_expected.to respond_to(:content) }

  describe "#content" do
    it "returns a string" do
      expect(question.content).to match "Is this a question?"
    end
  end

  context "when it has many answers" do
    before do
      5.times do |i|
        Answer.create(
          content:  "This is an answer. #{i}",
          user:     FactoryBot.create(:user),
          question:
        )
      end
    end

    its(:answer_count) { is_expected.to eq 5 }

    it "deletes the answers when deleted" do
      first_answer_id = question.answers.first.id
      question.destroy
      expect { Answer.find(first_answer_id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#ordered_answers" do
    let(:normal_user) { FactoryBot.create(:user) }

    let(:blocked_user) { FactoryBot.create(:user) }

    let(:muted_user) { FactoryBot.create(:user) }

    let!(:answer_from_normal_user) do
      FactoryBot.create(
        :answer,
        user:     normal_user,
        content:  "answer from a normal user",
        question:
      )
    end

    let!(:answer_from_blocked_user) do
      FactoryBot.create(
        :answer,
        user:     blocked_user,
        content:  "answer from a blocked user",
        question:
      )
    end

    let!(:answer_from_muted_user) do
      FactoryBot.create(
        :answer,
        user:     muted_user,
        content:  "answer from a blocked user",
        question:
      )
    end

    subject { question.ordered_answers }

    it "includes all answers to questions" do
      expect(subject).to include(answer_from_normal_user)
      expect(subject).to include(answer_from_blocked_user)
      expect(subject).to include(answer_from_muted_user)
    end

    context "when given a current user who blocks and mutes some users" do
      before do
        user.block blocked_user
        user.mute muted_user
      end

      subject { question.ordered_answers current_user: user }

      it "only includes answers to questions from users the user doesn't block or mute" do
        expect(subject).to include(answer_from_normal_user)
        expect(subject).not_to include(answer_from_blocked_user)
        expect(subject).not_to include(answer_from_muted_user)
      end
    end
  end
end
