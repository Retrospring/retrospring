# frozen_string_literal: true

require "rails_helper"

describe "about/index_advanced.html.haml", type: :view do
  before do
    stub_const("APP_CONFIG", {
                 "hostname" => "example.com",
                 "https"    => true,
                 "sitename" => "yastask",
               },)
  end

  subject(:rendered) { render }

  context "registrations are enabled" do
    before do
      allow(APP_CONFIG).to receive(:dig).with(:features, :registration, :enabled).and_return(true)
    end

    it "has references to registering now" do
      expect(rendered).to match(/Register now/)
    end
  end

  context "registrations are disabled" do
    before do
      allow(APP_CONFIG).to receive(:dig).with(:features, :registration, :enabled).and_return(false)
    end

    it "has no references to registering now" do
      expect(rendered).to_not match(/Register now/)
    end
  end
end
