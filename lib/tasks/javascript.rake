# frozen_string_literal: true

namespace :javascript do
  desc "Build your JavaScript bundle"
  task :build do
    command = "yarn install && yarn build"
    command += " --minify" if Rails.env.production?

    raise "Ensure yarn is installed and `yarn build` runs without errors" unless system command
  end
end

Rake::Task["assets:precompile"].enhance(["javascript:build"])
