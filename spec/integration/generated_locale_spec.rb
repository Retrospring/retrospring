# frozen_string_literal: true

require "rails_helper"

describe "test locale generation" do
  before(:context) { Rails.application.load_tasks }

  it "succeeds" do
    allow($stdout).to receive(:puts)

    Rake::Task["locale:generate"].invoke

    %w[activerecord controllers errors frontend views voc].each do |locale_type|
      expect($stdout).to have_received(:puts).with a_string_including("generating #{locale_type}.en-xx.yml")
    end
  end
end
