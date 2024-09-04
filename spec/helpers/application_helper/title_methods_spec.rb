# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper::TitleMethods, type: :helper do
  let(:user) { FactoryBot.create(:user) }
  let(:current_user) { user } # we can't use the `current_user` helper here, because it's not defined in the helper we're testing

  before do
    stub_const("APP_CONFIG", {
                 "site_name"      => "Waschmaschine",
                 "anonymous_name" => "Anonymous",
                 "https"          => true,
                 "items_per_page" => 5,
                 "sharing"        => {},
               },)

    user.profile.display_name = "Cool Man"
    user.profile.save!
  end

  describe "#generate_title" do
    it "should generate a proper title" do
      expect(generate_title("Simon", "says:", "Nice!")).to eq("Simon says: Nice! | Waschmaschine")
    end

    it "should only append a single quote to names that end with s" do
      expect(generate_title("Andreas", "says:", "Cool!", true)).to eq("Andreas' says: Cool! | Waschmaschine")
    end

    it "should cut content that is too long" do
      expect(generate_title("A title", "with", "a" * 50)).to eq("A title with aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… | Waschmaschine")
    end
  end
end
