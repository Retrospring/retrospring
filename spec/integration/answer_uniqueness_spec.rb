# frozen_string_literal: true

require "rails_helper"

describe "Answer uniqueness" do
  let(:user) { FactoryBot.build(:user) }
  let(:question) { FactoryBot.create(:question) }

  subject { 2.times { user.answer(question, "random") } }

  it "does not allow answering the same question twice" do
    expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
