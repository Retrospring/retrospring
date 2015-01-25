# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

namespace :justask do
  desc "Recount everything!"
  task recount: :environment do
    format = '%t (%c/%C) [%b>%i] %e'
    total = User.count
    progress = ProgressBar.create title: 'Processing users', format: format, starting_at: 0, total: total
    User.all.each do |user|
      begin
        answered = Answer.where(user: user).count
        asked = Question.where(user: user).where(author_is_anonymous: false).count
        commented = Comment.where(user: user).count
        smiled = Smile.where(user: user).count
        user.friend_count = user.friends.count
        user.follower_count = user.followers.count
        user.answered_count = answered
        user.asked_count = asked
        user.commented_count = commented
        user.smiled_count = smiled
        user.save!
      end
      progress.increment
    end

    total = Question.count
    progress = ProgressBar.create title: 'Processing questions', format: format, starting_at: 0, total: total
    Question.all.each do |question|
      begin
        answers = Answer.where(question: question).count
        question.answer_count = answers
        question.save!
      end
      progress.increment
    end

    total = Answer.count
    progress = ProgressBar.create title: 'Processing answers', format: format, starting_at: 0, total: total
    Answer.all.each do |answer|
      begin
        smiles = Smile.where(answer: answer).count
        comments = Comment.where(answer: answer).count
        answer.comment_count = comments
        answer.smile_count = smiles
        answer.save!
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
    puts "#{user.screen_name} is now an admin."
  end

  desc "Removes admin status from an user."
  task :deadmin, [:screen_name] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    user.admin = false
    user.save!
    puts "#{user.screen_name} is no longer an admin."
  end

  desc "Gives moderator status to an user."
  task :mod, [:screen_name] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    user.moderator = true
    user.save!
    puts "#{user.screen_name} is now an moderator."
  end

  desc "Removes moderator status from an user."
  task :demod, [:screen_name] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    user.moderator = false
    user.save!
    puts "#{user.screen_name} is no longer an moderator."
  end

  desc "Hits an user with the banhammer."
  task :ban, [:screen_name] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    user.banned = true
    user.save!
    puts "#{user.screen_name} got hit by\033[5m YE OLDE BANHAMMER\033[0m!!1!"
  end

  desc "Removes banned status from an user."
  task :unban, [:screen_name] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    user.banned = false
    user.save!
    puts "#{user.screen_name} is no longer banned."
  end

  desc "Gives blogger status to an user."
  task :blog, [:screen_name] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    user.blogger = true
    user.save!
    puts "#{user.screen_name} is now a blogger."
  end

  desc "Removes blogger status from an user."
  task :unblog, [:screen_name] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    user.blogger = false
    user.save!
    puts "#{user.screen_name} is no longer a blogger."
  end

  desc "Gives supporter status to an user."
  task :sup, [:screen_name] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    user.supporter = true
    user.save!
    puts "#{user.screen_name} is now an supporter."
  end

  desc "Removes supporter status from an user."
  task :desup, [:screen_name] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    user.supporter = false
    user.save!
    puts "#{user.screen_name} is no longer an supporter."
  end

  desc "Lists all users."
  task lusers: :environment do
    User.all.each do |u|
      puts "#{sprintf "%3d", u.id}. #{u.screen_name}"
    end
  end

  desc "Fixes the notifications"
  task fix_notifications: :environment do
    format = '%t (%c/%C) [%b>%i] %e'
    total = Notification.count
    progress = ProgressBar.create title: 'Processing notifications', format: format, starting_at: 0, total: total
    destroyed_count = 0

    Notification.all.each do |n|
      if n.target.nil?
        n.destroy
        destroyed_count += 1
      end
      progress.increment
    end

    puts "Purged #{destroyed_count} dead notifications."
  end

  desc "Fixes everything else"
  task fix_db: :environment do
    format = '%t (%c/%C) [%b>%i] %e'
    destroyed_count = {
        inbox: 0,
        question: 0,
        answer: 0,
        smile: 0,
        comment: 0
    }

    total = Inbox.count
    progress = ProgressBar.create title: 'Processing inboxes', format: format, starting_at: 0, total: total
    Inbox.all.each do |n|
      if n.question.nil?
        n.destroy
        destroyed_count[:inbox] += 1
      end
      progress.increment
    end

    total = Question.count
    progress = ProgressBar.create title: 'Processing questions', format: format, starting_at: 0, total: total
    Question.all.each do |q|
      if q.user.nil?
        q.user_id = nil
        q.author_is_anonymous = true
        destroyed_count[:question] += 1
      end
      progress.increment
    end

    total = Answer.count
    progress = ProgressBar.create title: 'Processing answers', format: format, starting_at: 0, total: total
    Answer.all.each do |a|
      if a.user.nil? or a.question.nil?
        a.destroy
        destroyed_count[:answer] += 1
      end
      progress.increment
    end

    total = Comment.count
    progress = ProgressBar.create title: 'Processing comments', format: format, starting_at: 0, total: total
    Comment.all.each do |c|
      if c.user.nil? or c.answer.nil?
        c.destroy
        destroyed_count[:comment] += 1
      end
      progress.increment
    end

    puts "Purged #{destroyed_count[:inbox]} dead inbox entries."
    puts "Marked #{destroyed_count[:question]} questions as anonymous."
    puts "Purged #{destroyed_count[:answer]} dead answers."
    puts "Purged #{destroyed_count[:answer]} dead comments."
  end

  desc "Prints lonely people."
  task loners: :environment do
    people = {}
    Question.all.each do |q|
      if q.author_is_anonymous and q.author_name != 'justask'
        q.answers.each do |a|
          if q.user == a.user
            people[q.user.screen_name] ||= 0
            people[q.user.screen_name] += 1
            puts "#{q.user.screen_name} -- answer id #{a.id}"
          end
        end
      end
    end

    max = 0
    res = []
    people.each { |k, v| max = v if v > max }
    people.each { |k, v| res << k if v == max }
    if res.length == 0
      puts "No one?  I hope you're just on the development session."
    else
      puts res.length == 1 ? "And the winner is..." : "And the winners are..."
      print "\033[5;31m"
      res.each { |name| puts " - #{name}" }
      print "\033[0m"
    end
  end
end
