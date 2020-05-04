# frozen_string_literal: true

RSpec.shared_context "AjaxController context" do
  let(:user) { FactoryBot.create(:user) }

  shared_examples "returns the expected response" do
    it "returns the expected response" do
      expect(JSON.parse(subject.body)).to match(expected_response)
    end
  end
end

RSpec.configure do |c|
  c.include_context "AjaxController context", ajax_controller: true
end
