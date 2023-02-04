# frozen_string_literal: true

require "rails_helper"
require "support/load_rake_tasks"

describe "test javascript building" do
  it "succeeds" do
    Rake::Task["javascript:build"].execute

    expect { Rails.root.join("app/assets/builds/application.js").open }.to_not raise_error
  end
end
