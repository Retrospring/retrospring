# frozen_string_literal: true

require "rails_helper"

require "use_case/data_export/inbox_entries"

describe UseCase::DataExport::InboxEntries, :data_export do
  include ActiveSupport::Testing::TimeHelpers

  context "when user doesn't have anything in their inbox" do
    it "returns an empty set of inbox entries" do
      expect(json_file("inbox_entries.json")).to eq(
        {
          inbox_entries: []
        }
      )
    end
  end

  context "when user has some questions in their inbox" do
    let!(:inbox_entries) do
      [
        # using `Inbox.create` here as for some reason FactoryBot.create(:inbox) always sets `new` to `nil`???
        travel_to(Time.utc(2022, 12, 10, 13, 37, 42)) { Inbox.create(user:, question: FactoryBot.create(:question), new: false) },
        travel_to(Time.utc(2022, 12, 10, 13, 39, 21)) { Inbox.create(user:, question: FactoryBot.create(:question), new: true) }
      ]
    end

    it "returns the inbox entries as json" do
      expect(json_file("inbox_entries.json")).to eq(
        {
          inbox_entries: [
            {
              id:          inbox_entries[0].id,
              user_id:     user.id,
              question_id: inbox_entries[0].question_id,
              new:         false,
              created_at:  "2022-12-10T13:37:42.000Z",
              updated_at:  "2022-12-10T13:37:42.000Z"
            },
            {
              id:          inbox_entries[1].id,
              user_id:     user.id,
              question_id: inbox_entries[1].question_id,
              new:         true,
              created_at:  "2022-12-10T13:39:21.000Z",
              updated_at:  "2022-12-10T13:39:21.000Z"
            }
          ]
        }
      )
    end
  end
end
