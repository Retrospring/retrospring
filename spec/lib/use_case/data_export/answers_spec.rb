# frozen_string_literal: true

require "rails_helper"

describe UseCase::DataExport::Answers, :data_export do
  include ActiveSupport::Testing::TimeHelpers

  context "when user doesn't have any answers" do
    it "returns an empty set of answers" do
      expect(json_file("answers.json")).to eq(
        {
          answers: [],
        },
      )
    end
  end

  context "when user has made some answer" do
    let!(:answer) do
      travel_to(Time.utc(2022, 12, 10, 13, 37, 42)) { FactoryBot.create(:answer, user:, content: "Yay, data export!", question: FactoryBot.build(:question, content: "awoo?")) }
    end

    it "returns the answers as json" do
      expect(json_file("answers.json")).to eq(
        {
          answers: [
            {
              id:            answer.id,
              content:       "Yay, data export!",
              question_id:   answer.question.id,
              comment_count: 0,
              user_id:       user.id,
              created_at:    "2022-12-10T13:37:42.000Z",
              updated_at:    "2022-12-10T13:37:42.000Z",
              smile_count:   0,
              pinned_at:     nil,
              related:       {
                question: {
                  id:         answer.question.id,
                  anonymous:  true,
                  generated:  false,
                  direct:     true,
                  author:     nil,
                  content:    "awoo?",
                  created_at: "2022-12-10T13:37:42.000Z",
                },
                comments: [],
              },
            }
          ],
        },
      )
    end
  end

  context "when user has made plenty of answers to many different question types" do
    let(:other_user) { FactoryBot.create(:user, screen_name: "TomTurbo") }

    let!(:questions) do
      [
        travel_to(Time.utc(2024, 8, 6, 13, 12, 0)) { FactoryBot.create(:question, user: other_user, content: "Sieben Zwiebeln sieden Bienen auf Trieben", author_is_anonymous: false, direct: false) },
        travel_to(Time.utc(2024, 8, 6, 13, 37, 42)) { FactoryBot.create(:question, user:, content: "Direct question from myself, to myself!", author_is_anonymous: false, direct: true) },
        travel_to(Time.utc(2024, 8, 6, 13, 37, 42)) { FactoryBot.create(:question, user:, content: "The funny lasaganga in oven question", author_is_anonymous: true, direct: true, author_identifier: "justask") },
        travel_to(Time.utc(2024, 8, 6, 13, 37, 42)) { FactoryBot.create(:question, user:, content: "Export is ready", author_is_anonymous: true, direct: true, author_identifier: "retrospring_exporter") },
        travel_to(Time.utc(2024, 8, 6, 13, 37, 50)) { FactoryBot.create(:question, user:, content: "delete your account", author_is_anonymous: true, direct: true) }
      ]
    end

    let!(:answers) do
      questions.map.with_index do |question, i|
        travel_to(Time.utc(2024, 8, 6, 13, 37, i)) do
          FactoryBot.create(:answer, user:, content: "Yay, data export!", question:)
        end
      end
    end

    let!(:answer_with_unknown_question) do
      travel_to(Time.utc(2024, 8, 6, 13, 38, 0)) do
        FactoryBot.create(:answer, user:, content: "aeeeugh???").tap { _1.update_column(:question_id, 666) } # rubocop:disable Rails/SkipsModelValidations
      end
    end

    it "returns the answers as json" do
      expect(json_file("answers.json")).to eq(
        {
          answers: [
            {
              id:            answers[0].id,
              content:       "Yay, data export!",
              question_id:   questions[0].id,
              comment_count: 0,
              user_id:       user.id,
              created_at:    "2024-08-06T13:37:00.000Z",
              updated_at:    "2024-08-06T13:37:00.000Z",
              smile_count:   0,
              pinned_at:     nil,
              related:       {
                question: {
                  id:         questions[0].id,
                  anonymous:  false,
                  generated:  false,
                  direct:     false,
                  author:     {
                    id:          other_user.id,
                    screen_name: "TomTurbo",
                  },
                  content:    "Sieben Zwiebeln sieden Bienen auf Trieben",
                  created_at: "2024-08-06T13:12:00.000Z",
                },
                comments: [],
              },
            },
            {
              id:            answers[1].id,
              content:       "Yay, data export!",
              question_id:   questions[1].id,
              comment_count: 0,
              user_id:       user.id,
              created_at:    "2024-08-06T13:37:01.000Z",
              updated_at:    "2024-08-06T13:37:01.000Z",
              smile_count:   0,
              pinned_at:     nil,
              related:       {
                question: {
                  id:         questions[1].id,
                  anonymous:  false,
                  generated:  false,
                  direct:     true,
                  author:     {
                    id:          user.id,
                    screen_name: user.screen_name,
                  },
                  content:    "Direct question from myself, to myself!",
                  created_at: "2024-08-06T13:37:42.000Z",
                },
                comments: [],
              },
            },
            {
              id:            answers[2].id,
              content:       "Yay, data export!",
              question_id:   questions[2].id,
              comment_count: 0,
              user_id:       user.id,
              created_at:    "2024-08-06T13:37:02.000Z",
              updated_at:    "2024-08-06T13:37:02.000Z",
              smile_count:   0,
              pinned_at:     nil,
              related:       {
                question: {
                  id:         questions[2].id,
                  anonymous:  true,
                  generated:  true,
                  direct:     true,
                  author:     nil,
                  content:    "The funny lasaganga in oven question",
                  created_at: "2024-08-06T13:37:42.000Z",
                },
                comments: [],
              },
            },
            {
              id:            answers[3].id,
              content:       "Yay, data export!",
              question_id:   questions[3].id,
              comment_count: 0,
              user_id:       user.id,
              created_at:    "2024-08-06T13:37:03.000Z",
              updated_at:    "2024-08-06T13:37:03.000Z",
              smile_count:   0,
              pinned_at:     nil,
              related:       {
                question: {
                  id:         questions[3].id,
                  anonymous:  true,
                  generated:  true,
                  direct:     true,
                  author:     nil,
                  content:    "Export is ready",
                  created_at: "2024-08-06T13:37:42.000Z",
                },
                comments: [],
              },
            },
            {
              id:            answers[4].id,
              content:       "Yay, data export!",
              question_id:   questions[4].id,
              comment_count: 0,
              user_id:       user.id,
              created_at:    "2024-08-06T13:37:04.000Z",
              updated_at:    "2024-08-06T13:37:04.000Z",
              smile_count:   0,
              pinned_at:     nil,
              related:       {
                question: {
                  id:         questions[4].id,
                  anonymous:  true,
                  generated:  false,
                  direct:     true,
                  author:     nil,
                  content:    "delete your account",
                  created_at: "2024-08-06T13:37:50.000Z",
                },
                comments: [],
              },
            },
            {
              id:            answer_with_unknown_question.id,
              content:       "aeeeugh???",
              question_id:   666,
              comment_count: 0,
              user_id:       user.id,
              created_at:    "2024-08-06T13:38:00.000Z",
              updated_at:    "2024-08-06T13:38:00.000Z",
              smile_count:   0,
              pinned_at:     nil,
              related:       {
                question: nil,
                comments: [],
              },
            }
          ],
        },
      )
    end
  end

  context "when user has made an answers that received comments" do
    let(:other_user) { FactoryBot.create(:user, screen_name: "TomTurbo") }

    let!(:question) do
      travel_to(Time.utc(2024, 8, 6, 13, 12, 0)) { FactoryBot.create(:question, user: other_user, content: "Sieben Zwiebeln sieden Bienen auf Trieben", author_is_anonymous: false, direct: false) }
    end

    let!(:answer) do
      travel_to(Time.utc(2024, 8, 6, 13, 38, 0)) { FactoryBot.create(:answer, user:, content: "Interessante Frage", question:) }
    end

    let!(:comments) do
      [
        travel_to(Time.utc(2024, 8, 6, 13, 40, 0)) { FactoryBot.create(:comment, user:, answer:, content: "Kein Kommentar") },
        travel_to(Time.utc(2024, 8, 6, 13, 42, 0)) { FactoryBot.create(:comment, user:, answer:, content: "Sehr witzig") },
        travel_to(Time.utc(2024, 8, 6, 13, 41, 0)) { FactoryBot.create(:comment, user: other_user, answer:, content: "Jo eh.", smile_count: 1) }
      ]
    end

    it "returns the answers as json" do
      expect(json_file("answers.json")).to eq(
        {
          answers: [
            {
              id:            answer.id,
              content:       "Interessante Frage",
              question_id:   answer.question.id,
              comment_count: 3,
              user_id:       user.id,
              created_at:    "2024-08-06T13:38:00.000Z",
              updated_at:    "2024-08-06T13:38:00.000Z",
              smile_count:   0,
              pinned_at:     nil,
              related:       {
                question: {
                  id:         answer.question.id,
                  anonymous:  false,
                  generated:  false,
                  direct:     false,
                  author:     {
                    id:          other_user.id,
                    screen_name: "TomTurbo",
                  },
                  content:    "Sieben Zwiebeln sieden Bienen auf Trieben",
                  created_at: "2024-08-06T13:12:00.000Z",
                },
                comments: [
                  {
                    id:          comments[0].id,
                    author:      {
                      id:          user.id,
                      screen_name: user.screen_name,
                    },
                    smile_count: 0,
                    content:     "Kein Kommentar",
                    created_at:  "2024-08-06T13:40:00.000Z",
                  },
                  {
                    id:          comments[2].id,
                    author:      {
                      id:          other_user.id,
                      screen_name: other_user.screen_name,
                    },
                    smile_count: 1,
                    content:     "Jo eh.",
                    created_at:  "2024-08-06T13:41:00.000Z",
                  },
                  {
                    id:          comments[1].id,
                    author:      {
                      id:          user.id,
                      screen_name: user.screen_name,
                    },
                    smile_count: 0,
                    content:     "Sehr witzig",
                    created_at:  "2024-08-06T13:42:00.000Z",
                  }
                ],
              },
            }
          ],
        },
      )
    end
  end
end
