# frozen_string_literal: true

require "rails_helper"

describe WellKnown::NodeInfoController do
  describe "#discovery" do
    subject { get :discovery }

    it "returns the expected response" do
      subject
      parsed = JSON.parse(response.body)
      expect(parsed).to eq({
                             "links" => [
                               {
                                 "rel"  => "http://nodeinfo.diaspora.software/ns/schema/2.1",
                                 "href" => "http://test.host/nodeinfo/2.1"
                               }
                             ]
                           })
    end
  end

  describe "#nodeinfo" do
    subject { get :nodeinfo }

    it "is valid as specified by the schema" do
      get(:discovery)
      schema = response.body
      subject
      parsed = JSON.parse(response.body)
      messages = JSON::Validator.fully_validate(schema, parsed)

      expect(messages).to be_empty
    end

    context "version is 2023.0102.1" do
      before do
        allow(Retrospring::Version).to receive(:to_s).and_return("2023.0102.1")
      end

      it "returns the correct version" do
        subject
        parsed = JSON.parse(response.body)
        expect(parsed["software"]).to eq({
                                           "name"       => "Retrospring",
                                           "version"    => "2023.0102.1",
                                           "repository" => "https://github.com/Retrospring/retrospring"
                                         })
      end
    end

    context "Twitter integration enabled" do
      before do
        stub_const("APP_CONFIG", {
                     "sharing" => {
                       "twitter" => {
                         "enabled" => true
                       }
                     }
                   })
      end

      it "includes Twitter in outbound services" do
        subject
        parsed = JSON.parse(response.body)
        expect(parsed.dig("services", "outbound")).to include("twitter")
      end
    end

    context "Twitter integration disabled" do
      before do
        stub_const("APP_CONFIG", {
                     "sharing" => {
                       "twitter" => {
                         "enabled" => false
                       }
                     }
                   })
      end

      it "includes Twitter in outbound services" do
        subject
        parsed = JSON.parse(response.body)
        expect(parsed.dig("services", "outbound")).to_not include("twitter")
      end
    end

    context "site has users" do
      let(:num_users) { rand(10..50) }

      before do
        FactoryBot.create_list(:user, num_users)
      end

      it "includes the correct user count" do
        subject
        parsed = JSON.parse(response.body)
        expect(parsed.dig("usage", "users", "total")).to eq(num_users)
      end
    end
  end
end
