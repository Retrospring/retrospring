# frozen_string_literal: true

RSpec.shared_examples_for "touches user timestamp" do |timestamp_column|
  include ActiveSupport::Testing::TimeHelpers

  it "touches #{timestamp_column}" do
    travel_to(1.day.from_now) do
      expect { subject }.to change { user.reload.send(timestamp_column) }.to(DateTime.now)
    end
  end
end
