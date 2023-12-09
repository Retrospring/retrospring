# frozen_string_literal: true

require "rails_helper"

describe "inbox/_entry.html.haml", type: :view do
  let(:inbox_entry)         { Inbox.create(user: inbox_user, question:, new:) }
  let(:inbox_user)          { user }
  let(:user)                { FactoryBot.create(:user, sharing_enabled:, sharing_custom_url:) }
  let(:sharing_enabled)     { true }
  let(:sharing_custom_url)  { nil }
  let(:question)            { FactoryBot.create(:question, content: "owo what's this?", author_is_anonymous:, user: question_user, answer_count:, direct: false) }
  let(:author_is_anonymous) { true }
  let(:question_user)       { nil }
  let(:answer_count)        { 0 }
  let(:new)                 { false }

  before do
    sign_in user
  end

  subject(:rendered) do
    render partial: "inbox/entry", locals: {
      i: inbox_entry,
    }
  end

  it "does not set the inbox-entry--new class on non-new inbox entries" do
    html = Nokogiri::HTML.parse(rendered)
    classes = html.css("#inbox_#{inbox_entry.id}").attr("class").value
    expect(classes).not_to include "inbox-entry--new"
  end

  context "when the inbox entry is new" do
    let(:new) { true }

    it "sets the inbox-entry--new class" do
      html = Nokogiri::HTML.parse(rendered)
      classes = html.css("#inbox_#{inbox_entry.id}").attr("class").value
      expect(classes).to include "inbox-entry--new"
    end
  end

  context "when question author is not anonymous" do
    let(:question_user)       { FactoryBot.create(:user) }
    let(:author_is_anonymous) { false }

    it "has an avatar" do
      expect(rendered).to have_css(%(img.question__avatar))
    end

    it "does not have an icon indicating the author is anonymous" do
      expect(rendered).not_to have_css(%(i.fas.fa-user-secret))
    end

    context "when the question already has some answers" do
      let(:answer_count) { 9001 }

      it "has a link to the question view" do
        html = Nokogiri::HTML.parse(rendered)
        selector = %(a[href="/@#{question_user.screen_name}/q/#{question.id}"])
        expect(rendered).to have_css(selector)
        expect(html.css(selector).text.strip).to eq "9001 answers"
      end
    end
  end

  it "has an icon indicating the author is anonymous" do
    expect(rendered).to have_css(%(i.fas.fa-user-secret))
  end

  it "contains the question text" do
    expect(rendered).to match "owo what's this?"
  end

  it "has interactive elements" do
    expect(rendered).to have_css(%(textarea[name="ib-answer"][data-id="#{inbox_entry.id}"]))
    expect(rendered).to have_css(%(button[name="ib-answer"][data-ib-id="#{inbox_entry.id}"]))
    expect(rendered).to have_css(%(button[name="ib-destroy"][data-ib-id="#{inbox_entry.id}"]))
  end

  it "has a hidden sharing bit" do
    expect(rendered).to have_css(%(.inbox-entry__sharing.d-none))
  end

  it "has a link-button to share to telegram" do
    expect(rendered).to have_css(%(.inbox-entry__sharing a.btn[data-inbox-sharing-target="telegram"]))
  end

  it "has a link-button to share to tumblr" do
    expect(rendered).to have_css(%(.inbox-entry__sharing a.btn[data-inbox-sharing-target="tumblr"]))
  end

  it "has a link-button to share to twitter" do
    expect(rendered).to have_css(%(.inbox-entry__sharing a.btn[data-inbox-sharing-target="twitter"]))
  end

  it "has a link-button to copy to clipboard" do
    expected_attribute_selectors = %([data-controller="clipboard"][data-action="clipboard#copy"][data-inbox-sharing-target="clipboard"])
    expect(rendered).to have_css(%(.inbox-entry__sharing button.btn#{expected_attribute_selectors}))
  end

  it "does not have a link-button to share to a custom site" do
    expect(rendered).not_to have_css(%(.inbox-entry__sharing a.btn[data-inbox-sharing-target="custom"]))
  end

  context "when the user has a custom share url set" do
    let(:sharing_custom_url) { "https://pounced-on.me/share?text=" }

    it "has a link-button to share to a custom site" do
      html = Nokogiri::HTML.parse(rendered)
      selector = %(.inbox-entry__sharing a.btn[data-inbox-sharing-target="custom"])
      expect(rendered).to have_css(selector)
      expect(html.css(selector).text.strip).to eq "pounced-on.me"
    end
  end

  context "when the inbox entry does not belong to the current user" do
    let(:inbox_user) { FactoryBot.create(:user) }

    it "does not have any interactive elements" do
      expect(rendered).not_to have_css(%(textarea[name="ib-answer"][data-id="#{inbox_entry.id}"]))
      expect(rendered).not_to have_css(%(button[name="ib-answer"][data-ib-id="#{inbox_entry.id}"]))
      expect(rendered).not_to have_css(%(button[name="ib-destroy"][data-ib-id="#{inbox_entry.id}"]))
    end

    it "does not have the sharing bit" do
      expect(rendered).not_to have_css(%(.inbox-entry__sharing.d-none))
    end
  end
end
