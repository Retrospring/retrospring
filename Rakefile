# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

task :routes do
  puts "\n"
  Rake::Task['justask:einherjar'].invoke
end

namespace :justask do
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

  desc "generate GET tests"
  task teapot_man: :environment do
    str = "RSpec.describe 'API::Sleipnir' do
  before :all do
    @me                         = FactoryGirl.create :user
    @other                      = FactoryGirl.create :user
    @question                   = Question.create(content: 'This is a question.', user: @me)
    @answer                     = Answer.create(content: 'This is an answer.', user: @me, question: @question)
    @comment                    = Comment.create(content: 'This is a comment.', user: @me, answer: @answer)
    @inbox                      = Inbox.create(user: @me, question: @question, new: true)
    @smile                      = Smile.create(user: @me, answer: @answer)
    @comment_smile              = CommentSmile.create(user: @me, comment: @commnent)
    @report_answer              = Report.create(type: 'Reports::Answer', target_id: @answer.id, user: @me)
    @report_user                = Report.create(type: 'Reports::User', target_id: @me.id, user: @me)
    @report_question            = Report.create(type: 'Reports::Question', target_id: @question.id, user: @me)
    @report_comment             = Report.create(type: 'Reports::Comment', target_id: @comment.id, user: @me)
    @notification_comment       = Notification.create(recipient: @me, target: @comment, new: true)
    @notification_answer        = Notification.create(recipient: @me, target: @answer, new: true)
    @notification_question      = Notification.create(recipient: @me, target: @question, new: true)
    @notification_smile         = Notification.create(recipient: @me, target: @smile, new: true)
    @notification_comment_smile = Notification.create(recipient: @me, target: @comment_smile, new: true)
    @follow_me                  = Relationship.create(source: @me, target: @other)
    @follow_other               = Relationship.create(source: @other, target: @me)
    @moderation_comment         = ModerationComment.create(report: @report_answer, user: @me, content: 'This is a moderation comment')
    @moderation_vote            = ModerationVote.create(report: @report_answer, user: @me, upvote: true)
    @group                      = Group.create(user: @me, name: 'Group', display_name: 'This is a group')
    @group_member               = GroupMember.create(user: @other, group: @group)

    @app, @oa, @token = gen_oa_b @me
  end

  after :all do
    Warden.test_reset!
  end\n"

    API.routes.each do |route|
      info = route.instance_variable_get :@options
      next if info[:method] != 'GET'

      path    = info[:path]
      version = info[:version]
      unless version.nil? or version.blank?
        path = path.gsub /^\/:version/, "/#{version}"
      end

      path = path.gsub(/\(\/?\.:format\)$/, '.json')

      opath = path

      path = path.gsub(/\/:([a-zA-Z_]*)?id/, "/1")
      path = path.gsub(/\/:screen_name/, "/#\{@me.screen_name\}")

      str += "\n  it 'GET #{opath} should status less than 400 with authentication' do
    res = oa_get @token, \"#{Rails.application.routes.url_helpers.api_path}#{path}\"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end\n"
    end
    str += "end\n"

    File.open(Rails.root.join("spec/controllers/api/sleipnir/_base_api_spec.rb"), 'w') { |file| file.write(str) }
  end

  desc "API Routes"
  task einherjar: :environment do
    puts "Routes for API:"
    out = [[
      "Prefix",
      "Verb",
      "Path",
      "Description"
    ]]

    max = [6, 4]
    API.routes.each do |route|
      info = route.instance_variable_get :@options
      result = [
        info[:as] ? info[:as][0..27] : '',
        info[:method] ? info[:method][0..6] : 'ALL',
        info[:path],
        info[:description]
      ]

      version = info[:version]
      unless version.nil? or version.blank?
        result[2] = result[2].gsub /^\/:version/, "/#{version}"
      end

      result[2] = Rails.application.routes.url_helpers.api_path + result[2].gsub(/\(\/?\.:format\)$/, '')

      max[0] = [[28, result[0].length].min, max[0]].max
      max[1] = [[ 7, result[1].length].min, max[1]].max

      out.push result
    end

    format = "\e[35m%#{max[0]}s\e[0m %-#{max[1]}s %s"

    spaces = Array.new(max[0] + max[1] + 5).join ' '

    out.each do |route|
      desc = route.last
      puts format % route
      puts "%s\e[34m%s\e[0m" % [spaces, desc] unless desc.nil? or desc.blank?
    end
  end

  desc "API dump"
  task gungnir: :environment do
    puts API.routes.count.to_s + " Routes"
    API.routes.each do |route|
      info = route.instance_variable_get :@options

      puts "Method: #{info[:method]}"
      puts "Alias:  #{info[:as]}"

      url = info[:path]
      unless info[:version].nil? or info[:version].blank?
        url = url.gsub /^\/:version/, "/#{info[:version]}"
      end
      url = Rails.application.routes.url_helpers.api_path + url

      puts "Route:  #{url}"
      puts "Desc:   #{info[:description]}"
      unless info[:auth].nil?
        puts "Scopes: #{info[:auth][:scopes].join ', '}"
      end
      unless info[:settings][:throttle].nil?
        puts "Limit:  #{info[:settings][:throttle][:hourly]} requests per hour" unless info[:settings][:throttle][:hourly].nil?
        puts "Limit:  #{info[:settings][:throttle][:daily]} requests per day" unless info[:settings][:throttle][:daily].nil?
      end
      puts "Params: "
      info[:params].each do |key, value|
        next if key == "nanotime" or key == "id_to_string"
        puts "  #{key}"
        if value.is_a? String
          puts "    type: PATH"
          next
        end
        value.each do |a, b|
          puts "    #{a}: #{b.to_s}"
        end
      end
      puts ""
    end
  end

  desc "generate API docs in english"
  task api_doc: :environment do
    root_path = Rails.root.join "docs/api/en"
    api_path  = Rails.root.join "app/api"
    loaded    = {}
    data      = {}
    payloads  = {}
    API.routes.each do |route|
      info = route.instance_variable_get :@options

      version = info[:version]
      next if version.nil? or version.blank?

      url = info[:path].gsub(/^\/:version/, "/#{version}").gsub(/\(\/?\.:format\)$/, '.json')
      namespace = if info[:namespace].blank?
        ''
      else
        info[:namespace][1..info[:namespace].length]
      end
      url = url[2 + namespace.length + version.length..url.length]

      data[version] ||= {}
      data[version][namespace] ||= {}
      data[version][namespace][url] ||= {}
      data[version][namespace][url][info[:method]] = info

      if loaded[info[:version]].nil?
        loaded[info[:version]] = true
        Dir[api_path.join version, 'entities/*.rb'].each { |file| load file }

        m = "#{version.capitalize}::Entities".constantize

        payloads[version] = m.constants
      end
    end

    data.each do |version, version_data|
      version_path = root_path.join version
      FileUtils.mkdir_p version_path
      version_data.each do |namespace, endpoints|
        next if namespace == ''
        puts namespace
        namespace_path = version_path.join namespace
        FileUtils.mkdir_p namespace_path

        namespace_txt = "# /#{version}/#{namespace}\n\n## Formats\n\n- `json`\n- `msgpack`\n\n## Endpoints\n"
        endpoints.each do |endpoint, methods|
          chunks = endpoint.split('/')
          chunks = chunks[1, chunks.length - 2]
          endpoint_path = if chunks.nil? or chunks.length < 1
            namespace_path
          else
            namespace_path.join chunks.join '/'
          end

          FileUtils.mkdir_p endpoint_path

          endpoint_file = "#{namespace}#{endpoint.gsub(".json", '')}.md"
          endpoint_name = "#{namespace}#{endpoint}"

          if endpoint == '.json'
            endpoint      = "#{namespace}.json"
            endpoint_name = endpoint
            endpoint_file = "root/#{namespace}.md"
            FileUtils.mkdir_p version_path.join "root"
          end

          endpoint_txt = ""

          methods.each do |method, info|
            namespace_txt += "\n### [#{method} #{endpoint}](#{endpoint_file})\n\n`#{method} https://retrospring.net/api/#{version}/#{endpoint_name}`\n\n#{info[:settings][:description][:description]}\n"

            endpoint_txt = if endpoint_txt.blank?
              "# #{method} /#{version}/#{endpoint_name}\n"
            else
              endpoint_txt + "\n# #{method} /#{version}/#{endpoint_name}\n"
            end

            endpoint_txt += "\n#{info[:settings][:description][:description]}\n"

            params_txt = "\n## request parameters\n"

            info[:params].each do |key, value|
              next if key == "nanotime" or key == "id_to_string"

              params_txt += "\n- `#{key}`\n  - TODO: Write description"

              if value.is_a? String
                params_txt += "\n  - required\n  - type: TODO\n  - CAVEAT: This is a REQUEST PATH variable."
              else
                params_txt += "\n  - #{if value[:required] == true then "required" else "optional" end}" unless value[:required].nil?
                params_txt += "\n  - type: #{value[:type].split("::").last}" unless value[:type].nil?
                params_txt += "\n  - default: #{value[:default]}" unless value[:default].nil?
              end
            end

            if params_txt != "\n## request parameters\n"
              endpoint_txt += params_txt
              endpoint_txt += "\n"
            end

            caveats_txt = "\n## caveats\n"

            unless info[:auth].nil?
              caveats_txt += "\n### oauth scopes\n\n- #{info[:auth][:scopes].join '\n- '}\n"
            end

            unless info[:settings][:throttle].nil?
              period = info[:settings][:throttle][:period]
              limit = unless info[:settings][:throttle][:hourly].nil?
                period = "hour"
                info[:settings][:throttle][:hourly]
              else
                unless info[:settings][:throttle][:daily].nil?
                  period = "day"
                  info[:settings][:throttle][:daily]
                else
                  period = "#{period} seconds"
                  info[:settings][:throttle][:limit]
                end
              end

              caveats_txt += "\n### rate limit\n\nMax #{limit} requests every #{period}\n"
            end

            if caveats_txt != "\n## request parameters\n"
              endpoint_txt += caveats_txt
            end

            endpoint_txt += "\n## responses\n\nTODO\n\n## error codes\n\nTODO\n"
          end

          endpoint_txt += "\n##### last revised on: #{Time.now.strftime "%Y/%m/%d %H:%M"}\n"

          File.open(version_path.join(endpoint_file), "w") { |f| f.write(endpoint_txt) }
        end

        namespace_txt += "\n##### last revised on: #{Time.now.strftime "%Y/%m/%d %H:%M"}\n"

        File.open(version_path.join("#{namespace}.md"), "w") { |f| f.write(namespace_txt) }
      end
    end

    payloads.each do |version, version_data|
      version_path = root_path.join version, "payload"
      FileUtils.mkdir_p version_path
      version_data.each do |payload|
        filename = version_path.join(payload.to_s.underscore + ".md")
        File.open(filename, "w") { |f| f.write("# #{payload}\n\nTODO\n\n## example\n\nTODO\n\n##### last revised on: #{Time.now.strftime "%Y/%m/%d %H:%M"}\n")}
      end
    end
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
  task :permanently_ban, [:screen_name, :reason] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    user.permanently_banned = true
    user.ban_reason = args[:reason]
    user.save!
    puts "#{user.screen_name} got hit by\033[5m YE OLDE BANHAMMER\033[0m!!1!"
  end

  desc "Hits an user with the banhammer for one day."
  task :ban, [:screen_name, :reason] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    user.permanently_banned = false
    user.banned_until = DateTime.current + 1
    user.ban_reason = args[:reason]
    user.save!
    puts "#{user.screen_name} got hit by\033[5m YE OLDE BANHAMMER\033[0m!!1!"
  end

  desc "Hits an user with the banhammer for one week."
  task :week_ban, [:screen_name, :reason] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    user.permanently_banned = false
    user.banned_until = DateTime.current + 7
    user.ban_reason = args[:reason]
    user.save!
    puts "#{user.screen_name} got hit by\033[5m YE OLDE BANHAMMER\033[0m!!1!"
  end

  desc "Hits an user with the banhammer for one month."
  task :month_ban, [:screen_name, :reason] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    user.permanently_banned = false
    user.banned_until = DateTime.current + 30
    user.ban_reason = args[:reason]
    user.save!
    puts "#{user.screen_name} got hit by\033[5m YE OLDE BANHAMMER\033[0m!!1!"
  end

  desc "Hits an user with the banhammer for one year."
  task :year_ban, [:screen_name, :reason] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    user.permanently_banned = false
    user.banned_until = DateTime.current + 365
    user.ban_reason = args[:reason]
    user.save!
    puts "#{user.screen_name} got hit by\033[5m YE OLDE BANHAMMER\033[0m!!1!"
  end

  desc "Hits an user with the banhammer for one aeon."
  task :aeon_ban, [:screen_name, :reason] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    user.permanently_banned = false
    user.banned_until = DateTime.current + 365_000_000_000
    user.ban_reason = args[:reason]
    user.save!
    puts "#{user.screen_name} got hit by\033[5m YE OLDE BANHAMMER\033[0m!!1!"
  end

  desc "Removes banned status from an user."
  task :unban, [:screen_name] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    user.permanently_banned = false
    user.banned_until = nil
    user.ban_reason = nil
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

  desc "Gives contributor status to an user."
  task :contrib, [:screen_name] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    user.contributor = true
    user.save!
    puts "#{user.screen_name} is now a contributor."
  end

  desc "Removes contributor status from an user."
  task :decontrib, [:screen_name] => :environment do |t, args|
    fail "screen name required" if args[:screen_name].nil?
    user = User.find_by_screen_name(args[:screen_name])
    fail "user #{args[:screen_name]} not found" if user.nil?
    user.contributor = false
    user.save!
    puts "#{user.screen_name} is no longer a contributor."
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

  desc "Export data for an user"
  task :export, [:email] => :environment do |t, args|
    require 'json'
    require 'yaml'
    return if args[:email].nil?
    obj = {}
    format = '%t (%c/%C) [%b>%i] %e'
    u = User.where("LOWER(email) = ?", args[:email].downcase).first!
    export_dirname = "export_#{u.screen_name}_#{Time.now.to_i}"
    export_filename = u.screen_name

    %i(id screen_name display_name created_at sign_in_count last_sign_in_at friend_count follower_count asked_count answered_count commented_count smiled_count motivation_header bio website location moderator admin supporter banned blogger).each do |f|
      obj[f] = u.send f
    end

    total = u.questions.count
    progress = ProgressBar.create title: 'Processing questions', format: format, starting_at: 0, total: total
    obj[:questions] = []
    u.questions.each do |q|
      qobj = {}
      %i(id content author_is_anonymous created_at answer_count).each do |f|
        qobj[f] = q.send f
      end
      obj[:questions] << qobj
      progress.increment
    end

    total = u.answers.count
    progress = ProgressBar.create title: 'Processing answers', format: format, starting_at: 0, total: total
    obj[:answers] = []
    u.answers.each do |a|
      aobj = {}
      %i(id content comment_count smile_count created_at).each do |f|
        aobj[f] = a.send f
      end
      aobj[:question] = {}
      %i(id content author_is_anonymous created_at answer_count).each do |f|
        aobj[:question][f] = a.question.send f
      end
      aobj[:question][:user] = a.question.user.screen_name unless a.question.author_is_anonymous
      aobj[:comments] = []
      a.comments.each do |c|
        cobj = {}
        %i(id content created_at).each do |f|
          cobj[f] = c.send f
        end
        cobj[:user] = c.user.screen_name
        aobj[:comments] << cobj
      end
      obj[:answers] << aobj
      progress.increment
    end

    total = u.comments.count
    progress = ProgressBar.create title: 'Processing comments', format: format, starting_at: 0, total: total
    obj[:comments] = []
    u.comments.each do |c|
      cobj = {}
      %i(id content created_at).each do |f|
        cobj[f] = c.send f
      end
      cobj[:answer] = {}
      %i(id content comment_count smile_count created_at).each do |f|
        cobj[:answer][f] = c.answer.send f
      end
      cobj[:answer][:question] = {}
      %i(id content author_is_anonymous created_at answer_count).each do |f|
        cobj[:answer][:question][f] = c.answer.question.send f
      end
      cobj[:answer][:question][:user] = c.answer.question.user.screen_name unless c.answer.question.author_is_anonymous
      obj[:comments] << cobj
      progress.increment
    end

    total = u.smiles.count
    progress = ProgressBar.create title: 'Processing smiles', format: format, starting_at: 0, total: total
    obj[:smiles] = []
    u.smiles.each do |s|
      sobj = {}
      %i(id created_at).each do |f|
        sobj[f] = s.send f
      end

      sobj[:answer] = {}
      %i(id content comment_count smile_count created_at).each do |f|
        sobj[:answer][f] = s.answer.send f
      end
      sobj[:answer][:question] = {}
      %i(id content author_is_anonymous created_at answer_count).each do |f|
        sobj[:answer][:question][f] = s.answer.question.send f
      end
      sobj[:answer][:question][:user] = s.answer.question.user.screen_name unless s.answer.question.author_is_anonymous

      obj[:smiles] << sobj
      progress.increment
    end

    `mkdir -p /usr/home/justask/justask/public/export`
    `mkdir -p /tmp/rs_export/#{export_dirname}/picture`
    if u.profile_picture
      %i(large medium small original).each do |s|
        x = u.profile_picture.path(s).gsub('"', '\\"')
        `cp "#{x}" "/tmp/rs_export/#{export_dirname}/picture/#{s}_#{File.basename x}"`
      end
    end
    File.open "/tmp/rs_export/#{export_dirname}/#{export_filename}.json", 'w' do |f|
      f.puts obj.to_json
    end
    File.open "/tmp/rs_export/#{export_dirname}/#{export_filename}.yml", 'w' do |f|
      f.puts obj.to_yaml
    end
    `tar czvf public/export/#{export_dirname}.tar.gz -C /tmp/rs_export #{export_dirname}`
    puts "\033[1mhttps://retrospring.net/export/#{export_dirname}.tar.gz\033[0m"
  end
end
