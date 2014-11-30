# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

namespace :justask do
  desc "Recount every user's answer/question count."
  task recount: :environment do
    total = User.count
    progress = ProgressBar.create title: 'Processing user', format: "%t (%c/%C) [%b>%i] %e", starting_at: 0, total: total
    User.all.each do |user|
      begin
        answered = Answer.where(user: user).count
        asked = Question.where(user: user).where(author_is_anonymous: false).count
        commented = Comment.where(user: user).count
        user.friend_count = user.friends.count
        user.follower_count = user.followers.count
        user.answered_count = answered
        user.asked_count = asked
        user.commented_count = commented
        user.save!
      end
      progress.increment
    end
  end

  desc "Gives admin status to an user."
  task :admin, [:screen_name] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    user.admin = true
    user.save!
    puts "#{user.screen_name} is now an admin"
  end

  desc "Removes admin status from an user."
  task :deadmin, [:screen_name] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    user.admin = false
    user.save!
    puts "#{user.screen_name} no longer an admin"
  end

  desc "Lists all users."
  task lusers: :environment do
    User.all.each do |u|
      puts "#{sprintf "%3d", u.id}. #{u.screen_name}"
    end
  end
end
