# frozen_string_literal: true

require "rails_helper"

describe "inbox/show.turbo_stream.haml", type: :view do
  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  subject(:rendered) { render }

  context "with some inbox entries" do
    let(:inbox_entry1) { Inbox.create(user:, question: FactoryBot.create(:question)) }
    let(:inbox_entry2) { Inbox.create(user:, question: FactoryBot.create(:question)) }

    before do
      assign :inbox, [inbox_entry2, inbox_entry1]
    end

    it "appends to entries" do
      expect(rendered).to have_css(%(turbo-stream[action="append"][target="entries"]))
    end

    it "renders inbox entries" do
      expect(rendered).to have_css("#inbox_#{inbox_entry1.id}")
      expect(rendered).to have_css("#inbox_#{inbox_entry2.id}")
    end

    it "updates the paginator" do
      expect(rendered).to have_css(%(turbo-stream[action="update"][target="paginator"]))
    end

    context "when more data is available" do
      before do
        assign :more_data_available, true
        assign :inbox_last_id, 1337
      end

      it "has the correct params on the button" do
        expect(rendered).to have_css(%(input[type="hidden"][name="last_id"][value="1337"]))
        expect(rendered).not_to have_css(%(input[type="hidden"][name="author"]))
      end

      context "when passed an author" do
        before do
          assign :author, "jyrki"
        end

        it "has the correct params on the button" do
          expect(rendered).to have_css(%(input[type="hidden"][name="last_id"][value="1337"]))
          expect(rendered).to have_css(%(input[type="hidden"][name="author"]))
        end
      end
    end
  end
end
