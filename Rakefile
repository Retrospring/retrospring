# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("config/application", __dir__)

Rails.application.load_tasks

namespace :justask do
  desc "Gives admin status to a user."
  task :admin, [:screen_name] => :environment do |_t, args|
    abort "screen name required" if args[:screen_name].nil?

    user = User.find_by(screen_name: args[:screen_name])
    abort "user #{args[:screen_name]} not found" if user.nil?

    user.add_role :administrator
    puts "#{user.screen_name} is now an administrator."
  end

  desc "Removes admin status from a user."
  task :deadmin, [:screen_name] => :environment do |_t, args|
    abort "screen name required" if args[:screen_name].nil?

    user = User.find_by(screen_name: args[:screen_name])
    abort "user #{args[:screen_name]} not found" if user.nil?

    user.remove_role :administrator
    puts "#{user.screen_name} is no longer an administrator."
  end

  desc "Gives moderator status to a user."
  task :mod, [:screen_name] => :environment do |_t, args|
    abort "screen name required" if args[:screen_name].nil?

    user = User.find_by(screen_name: args[:screen_name])
    abort "user #{args[:screen_name]} not found" if user.nil?

    user.add_role :moderator
    puts "#{user.screen_name} is now a moderator."
  end

  desc "Removes moderator status from a user."
  task :demod, [:screen_name] => :environment do |_t, args|
    abort "screen name required" if args[:screen_name].nil?

    user = User.find_by(screen_name: args[:screen_name])
    abort "user #{args[:screen_name]} not found" if user.nil?

    user.remove_role :moderator
    puts "#{user.screen_name} is no longer a moderator."
  end

  desc "Removes users whose accounts haven't been verified for over 3 months."
  task remove_stale: :environment do
    puts "Removing stale users…"
    removed = User.where(confirmed_at: nil)
                  .where("confirmation_sent_at < ?", DateTime.now.utc - 3.months)
                  .destroy_all.count
    puts "Removed #{removed} users"
  end
end

namespace :db do
  namespace :schema do
    task create_timestampid_function: :environment do
      conn = ActiveRecord::Base.connection
      have_func = conn.execute("SELECT EXISTS(SELECT * FROM pg_proc WHERE proname = 'gen_timestamp_id');").values.first.first
      next if have_func

      statement = File.read(File.join(__dir__, "db/migrate/20200704163504_use_timestamped_ids.rb")).match(/<~SQL(?<stmt>.+)SQL$/m)[:stmt]
      conn.execute(statement)
    end

    task create_id_sequences: :environment do
      conn = ActiveRecord::Base.connection

      # required for the timestampid function to work properly
      %i[questions answers comments users mute_rules].each do |tbl|
        conn.execute("CREATE SEQUENCE IF NOT EXISTS #{tbl}_id_seq")
      end
    end
  end

  # create timestampid before loading schema
  Rake::Task["db:schema:load"].enhance ["db:schema:create_timestampid_function"]
  Rake::Task["db:test:load_schema"].enhance ["db:schema:create_timestampid_function"]
  # create id_sequences after loading schema
  Rake::Task["db:schema:load"].enhance do
    Rake::Task["db:schema:create_id_sequences"].invoke
  end
  Rake::Task["db:test:load_schema"].enhance do
    Rake::Task["db:schema:create_id_sequences"].invoke
  end
end
