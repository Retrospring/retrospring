# frozen_string_literal: true

namespace :css do
  desc "Build your CSS bundle"
  task :build do
    command = "yarn install && yarn build:css"
    command += " --style=compressed" if Rails.env.production?

    raise "Ensure yarn is installed and `yarn build:css` runs without errors" unless system command
  end
end

Rake::Task["assets:precompile"].enhance(["css:build"])
