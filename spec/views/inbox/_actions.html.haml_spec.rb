# frozen_string_literal: true

require "rails_helper"

describe "inbox/_actions.html.haml", type: :view do
  let(:delete_id) { "ib-delete-all" }
  let(:disabled) { false }

  let(:user) { FactoryBot.create(:user) }

  before do
    sign_in user
  end

  subject(:rendered) do
    render partial: "inbox/actions", locals: {
      delete_id:,
      disabled:,
      inbox_count: 4020,
    }
  end

  it "has a button for deleting all inbox entries" do
    html = Nokogiri::HTML.parse(rendered)
    button = html.css("button#ib-delete-all")
    expect(button).not_to have_attribute(:disabled)
  end

  context "with disabled = true" do
    let(:disabled) { true }

    it "has a button for deleting all inbox entries" do
      html = Nokogiri::HTML.parse(rendered)
      button = html.css("button#ib-delete-all")
      expect(button).to have_attribute(:disabled)
    end
  end

  context "with delete_id = ib-delete-all-author" do
    let(:delete_id) { "ib-delete-all-author" }

    it "has a button for deleting all inbox entries" do
      html = Nokogiri::HTML.parse(rendered)
      button = html.css("button#ib-delete-all-author")

      expect(button).to have_attribute("data-ib-count" => "4020")
    end
  end
end
