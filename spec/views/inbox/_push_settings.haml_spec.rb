# frozen_string_literal: true

require "rails_helper"

describe "inbox/_push_settings.haml", type: :view do
  subject(:rendered) { render }

  it "has a button to enable push notifications" do
    expect(rendered).to have_css(%(button[data-action="push-enable"]))
  end

  it "has a button to dismiss the view" do
    expect(rendered).to have_css(%(button[data-action="push-dismiss"]))
  end
end
