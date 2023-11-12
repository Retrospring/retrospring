# frozen_string_literal: true

require "rails_helper"

describe "actions/_share.html.haml", type: :view do
  let(:answer) { FactoryBot.create(:answer, user: FactoryBot.create(:user)) }

  subject(:rendered) do
    render partial: "actions/share", locals: {
      answer:,
    }
  end

  it "has a dropdown item to share to twitter" do
    expect(rendered).to have_css(%(a.dropdown-item[href^="https://twitter.com/"][target="_blank"]))
  end

  it "has a dropdown item to share to tumblr" do
    expect(rendered).to have_css(%(a.dropdown-item[href^="https://www.tumblr.com/"][target="_blank"]))
  end

  it "has a dropdown item to share to telegram" do
    expect(rendered).to have_css(%(a.dropdown-item[href^="https://t.me/"][target="_blank"]))
  end

  it "has a dropdown item to share to anywhere else" do
    expect(rendered).to have_css(%(a.dropdown-item[data-action="share#share"]))
  end

  it "has a dropdown item to copy to clipboard" do
    expect(rendered).to have_css(%(a.dropdown-item[data-action="clipboard#copy"]))
  end
end
