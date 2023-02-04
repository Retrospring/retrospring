# frozen_string_literal: true

require "rails_helper"
require "support/load_rake_tasks"

describe "test css building" do
  it "succeeds" do
    Rake::Task["css:build"].execute

    expect { Rails.root.join("app/assets/builds/application.css").open }.to_not raise_error
  end
end
