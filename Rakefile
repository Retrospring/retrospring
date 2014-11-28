# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

namespace :justask do
  desc "Recount every user's answer/question count."
  task recount: :environment do
    total = User.count
    progress = ProgressBar.create title: 'Processing user', format: "%t (%c/%C) [%b>%i] %e", starting_at: 1, total: total
    User.all do |user|
      begin
        answered = Question.where(user: user).count
        asked = Question.where(user: user).where(author_is_anonymous: false).count
        commented = Question.where(user: user).count
        user.answered_count = answered
        user.asked_count = asked
        user.commented_count = commented
        user.save!
      end
      progress.increment
    end
    puts
  end
end