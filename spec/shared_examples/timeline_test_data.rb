# frozen_string_literal: true

RSpec.shared_context "Timeline test data" do
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
end

RSpec.configure do |config|
  config.include_context "Timeline test data", timeline_test_data: true
end
