# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

task :default do
  Brakeman.run :app_path => ".", :print_report => true
end

namespace :justask do
  desc "Regenerate themes"
  task themes: :environment do
    format = '%t (%c/%C) [%b>%i] %e'

    all = Theme.all

    progress = ProgressBar.create title: 'Processing themes', format: format, starting_at: 0, total: all.count

    all.each do |theme|
      theme.touch
      theme.save!
      progress.increment
    end

    puts "regenerated #{all.count} themes"
  end

  desc "Upload to AWS"
  task paperclaws: :environment do
    if APP_CONFIG["fog"]["credentials"].nil? or APP_CONFIG["fog"]["credentials"]["provider"] != "AWS"
      throw "Needs fog (AWS) to be defined in justask.yml"
    end

    format = '%t (%c/%C) [%b>%i] %e'
    root = "#{Rails.root}/public/system"
    files = Dir["#{root}/**/*.*"]
    progress = ProgressBar.create title: 'Processing files', format: format, starting_at: 0, total: files.length

    # weird voodoo, something is causing just using "APP_CONFIG["fog"]["credentials"]" as Fog::Storage.new to cause an exception
    # TODO: Programmatically copy?
    credentials = {
      provider: "AWS",
      aws_access_key_id: APP_CONFIG["fog"]["credentials"]["aws_access_key_id"],
      aws_secret_access_key: APP_CONFIG["fog"]["credentials"]["aws_secret_access_key"],
      region: APP_CONFIG["fog"]["credentials"]["region"]
    }

    fog = Fog::Storage.new credentials
    bucket = fog.directories.get APP_CONFIG["fog"]["directory"]

    files.each do |file|
      bucket.files.create key: file[root.length + 1 ... file.length], body: File.open(file), public: true
      progress.increment
    end

    puts "hopefully uploaded #{files.length} files"
  end

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

  desc "Gives admin status to a user."
  task :admin, [:screen_name] => :environment do |t, args|
    abort "screen name required" if args[:screen_name].nil?

    user = User.find_by_screen_name(args[:screen_name])
    abort "user #{args[:screen_name]} not found" if user.nil?

    user.add_role :administrator
    puts "#{user.screen_name} is now an administrator."
  end

  desc "Removes admin status from a user."
  task :deadmin, [:screen_name] => :environment do |t, args|
    abort "screen name required" if args[:screen_name].nil?

    user = User.find_by_screen_name(args[:screen_name])
    abort "user #{args[:screen_name]} not found" if user.nil?

    user.remove_role :administrator
    puts "#{user.screen_name} is no longer an administrator."
  end

  desc "Gives moderator status to a user."
  task :mod, [:screen_name] => :environment do |t, args|
    abort "screen name required" if args[:screen_name].nil?

    user = User.find_by_screen_name(args[:screen_name])
    abort "user #{args[:screen_name]} not found" if user.nil?

    user.add_role :moderator
    puts "#{user.screen_name} is now a moderator."
  end

  desc "Removes moderator status from a user."
  task :demod, [:screen_name] => :environment do |t, args|
    abort "screen name required" if args[:screen_name].nil?

    user = User.find_by_screen_name(args[:screen_name])
    abort "user #{args[:screen_name]} not found" if user.nil?

    user.remove_role :moderator
    puts "#{user.screen_name} is no longer a moderator."
  end

  desc "Hits an user with the banhammer."
  task :permanently_ban, [:screen_name, :reason] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    UseCase::User::Ban.call(
      target_user_id: user.id,
      expiry: nil,
      reason: args[:reason],
    )
    puts "#{user.screen_name} got hit by\033[5m YE OLDE BANHAMMER\033[0m!!1!"
  end

  desc "Hits an user with the banhammer for one day."
  task :ban, [:screen_name, :reason] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    UseCase::User::Ban.call(
      target_user_id: user.id,
      expiry: DateTime.current + 1,
      reason: args[:reason],
    )
    puts "#{user.screen_name} got hit by\033[5m YE OLDE BANHAMMER\033[0m!!1!"
  end

  desc "Hits an user with the banhammer for one week."
  task :week_ban, [:screen_name, :reason] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    UseCase::User::Ban.call(
      target_user_id: user.id,
      expiry: DateTime.current + 7,
      reason: args[:reason],
      )
    puts "#{user.screen_name} got hit by\033[5m YE OLDE BANHAMMER\033[0m!!1!"
  end

  desc "Hits an user with the banhammer for one month."
  task :month_ban, [:screen_name, :reason] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    UseCase::User::Ban.call(
      target_user_id: user.id,
      expiry: DateTime.current + 30,
      reason: args[:reason],
      )
    puts "#{user.screen_name} got hit by\033[5m YE OLDE BANHAMMER\033[0m!!1!"
  end

  desc "Hits an user with the banhammer for one year."
  task :year_ban, [:screen_name, :reason] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    UseCase::User::Ban.call(
      target_user_id: user.id,
      expiry: DateTime.current + 365,
      reason: args[:reason],
    )
    puts "#{user.screen_name} got hit by\033[5m YE OLDE BANHAMMER\033[0m!!1!"
  end

  desc "Hits an user with the banhammer for one aeon."
  task :aeon_ban, [:screen_name, :reason] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    UseCase::User::Ban.call(
      target_user_id: user.id,
      expiry: DateTime.current + 365_000_000_000,
      reason: args[:reason],
    )
    puts "#{user.screen_name} got hit by\033[5m YE OLDE BANHAMMER\033[0m!!1!"
  end

  desc "Removes banned status from an user."
  task :unban, [:screen_name] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    UseCase::User::Unban.call(user.id)
    puts "#{user.screen_name} is no longer banned."
  end

  desc "Lists all users."
  task lusers: :environment do
    User.all.each do |u|
      puts "#{sprintf "%3d", u.id}. #{u.screen_name}"
    end
  end

  desc "Removes users whose accounts haven't been verified for over 3 months."
  task remove_stale: :environment do
    puts "Removing stale users…"
    removed = User.where(confirmed_at: nil)
        .where("confirmation_sent_at < ?", DateTime.now.utc - 3.months)
        .destroy_all.count
    puts "Removed #{removed} users"
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

  desc "Subscribes everyone to their answers"
  task fix_submarines: :environment do
    format = '%t (%c/%C) [%b>%i] %e'

    total = Answer.count
    progress = ProgressBar.create title: 'Processing answers', format: format, starting_at: 0, total: total
    subscribed = 0

    Answer.all.each do |a|
      if not a.user.nil?
        Subscription.subscribe a.user, a
        subscribed += 1
      end

      progress.increment
    end

    puts "Subscribed to #{subscribed} posts."
  end

  desc "Destroy lost subscriptions"
  task fix_torpedoes: :environment do
    format = '%t (%c/%C) [%b>%i] %e'

    total = Subscription.count
    progress = ProgressBar.create title: 'Processing subscriptions', format: format, starting_at: 0, total: total
    destroyed = 0
    Subscription.all.each do |s|
      if s.user.nil? or s.answer.nil?
        s.destroy
        destroyed += 1
      end

      progress.increment
    end

    puts "Put #{destroyed} subscriptions up for adoption."
  end

  desc "Fixes reports"
  task fix_reports: :environment do
    format = '%t (%c/%C) [%b>%i] %e'

    total = Report.count
    progress = ProgressBar.create title: 'Processing reports', format: format, starting_at: 0, total: total
    destroyed = 0
    Report.all.each do |r|
      if r.target.nil? and not r.deleted?
        r.deleted = true
        r.save
        destroyed += 1
      elsif r.user.nil?
        r.destroy
        destroyed += 1
      end
      progress.increment
    end

    puts "Marked #{destroyed} reports as deleted."
  end

  desc "Fixes everything else"
  task fix_db: :environment do
    format = '%t (%c/%C) [%b>%i] %e'
    destroyed_count = {
        inbox: 0,
        question: 0,
        answer: 0,
        smile: 0,
        comment: 0,
        subscription: 0,
        report: 0
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

    total = Subscription.count
    progress = ProgressBar.create title: 'Processing subscriptions', format: format, starting_at: 0, total: total
    Subscription.all.each do |s|
      if s.user.nil? or s.answer.nil?
        s.destroy
        destroyed_count[:subscription] += 1
      end

      progress.increment
    end

    total = Report.count
    progress = ProgressBar.create title: 'Processing reports', format: format, starting_at: 0, total: total
    Report.all.each do |r|
      if r.target.nil? and not r.deleted?
        r.deleted = true
        r.save
        destroyed_count[:report] += 1
      elsif r.user.nil?
        r.destroy
        destroyed_count[:report] += 1
      end
      progress.increment
    end

    puts "Put #{destroyed_count[:subscription]} subscriptions up for adoption."
    puts "Purged #{destroyed_count[:inbox]} dead inbox entries."
    puts "Marked #{destroyed_count[:question]} questions as anonymous."
    puts "Purged #{destroyed_count[:answer]} dead answers."
    puts "Purged #{destroyed_count[:comment]} dead comments."
    puts "Purged #{destroyed_count[:subscription]} dead subscriptions."
    puts "Marked #{destroyed_count[:report]} reports as deleted."
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

namespace :db do
  namespace :schema do
    task :create_timestampid_function do
      conn = ActiveRecord::Base.connection
      have_func = conn.execute("SELECT EXISTS(SELECT * FROM pg_proc WHERE proname = 'gen_timestamp_id');").values.first.first
      next if have_func

      statement = File.read(File.join(__dir__, 'db/migrate/20200704163504_use_timestamped_ids.rb')).match(/<~SQL(?<stmt>.+)SQL$/m)[:stmt]
      conn.execute(statement)
    end

    task :create_id_sequences do
      conn = ActiveRecord::Base.connection

      # required for the timestampid function to work properly
      %i[questions answers comments smiles comment_smiles users mute_rules].each do |tbl|
        conn.execute("CREATE SEQUENCE IF NOT EXISTS #{tbl}_id_seq")
      end
    end
  end

  # create timestampid before loading schema
  Rake::Task['db:schema:load'].enhance ['db:schema:create_timestampid_function']
  Rake::Task['db:test:load_schema'].enhance ['db:schema:create_timestampid_function']
  # create id_sequences after loading schema
  Rake::Task['db:schema:load'].enhance do
    Rake::Task['db:schema:create_id_sequences'].invoke
  end
  Rake::Task['db:test:load_schema'].enhance do
    Rake::Task['db:schema:create_id_sequences'].invoke
  end
end
