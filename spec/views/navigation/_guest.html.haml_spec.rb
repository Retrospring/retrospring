# frozen_string_literal: true

require "rails_helper"

describe "navigation/_guest.html.haml", type: :view do
  subject(:rendered) do
    render partial: "navigation/guest"
  end

  context "registrations are enabled" do
    before do
      allow(APP_CONFIG).to receive(:dig).with(:features, :registration, :enabled).and_return(true)
    end

    it "has no sign up link" do
      expect(rendered).to_not match(/Sign up/)
    end
  end

  context "registrations are disabled" do
    before do
      allow(APP_CONFIG).to receive(:dig).with(:features, :registration, :enabled).and_return(false)
    end

    it "has no sign up link" do
      expect(rendered).to_not match(/Sign up/)
    end
  end
end
