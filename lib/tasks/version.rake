# frozen_string_literal: true

namespace :version do
  desc "Bump the version"
  task bump: :environment do
    puts "Current version: #{Retrospring::Version}"
    current_ymd = %i[year month day].map { Retrospring::Version.public_send(_1) }

    now = Time.now.utc
    today_ymd = %i[year month day].map { now.public_send(_1) }

    version_path = Rails.root.join("lib/version.rb")
    version_contents = File.read(version_path)

    patch_contents = lambda do |key, val|
      version_contents.sub!(/def #{key} = .+/) { "def #{key} = #{val}" }
    end

    if current_ymd == today_ymd
      # bump the patch version
      patch_contents[:patch, Retrospring::Version.patch + 1]
    else
      # set year/month/day to today, and reset patch to 0
      %i[year month day].each { patch_contents[_1, now.public_send(_1)] }
      patch_contents[:patch, 0]
    end

    # write the file
    File.write(version_path, version_contents)

    # reload the version file
    load version_path
    puts "New version: #{Retrospring::Version}"
  end

  desc "Commit and tag a new release"
  task commit: :environment do
    version_path = Rails.root.join("lib/version.rb")

    puts "Committing version"
    sh %(git commit -m 'Bump version to #{Retrospring::Version}' -- #{version_path.to_s.inspect})

    puts "Tagging new release"
    sh %(git tag -a -m 'Bump version to #{Retrospring::Version}' #{Retrospring::Version})
  end

  desc "Update the version (bump + commit)"
  task update: %i[bump commit]
end
