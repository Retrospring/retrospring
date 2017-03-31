# config valid only for current version of Capistrano
lock "3.8.0"

set :application, "retrospring"
set :repo_url, "git@git.rrerr.net:nilsding/retrospring.git"

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/usr/home/justask/apps/retrospring"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/database.yml", "config/justask.yml", "config/secrets.yml", "config/initializers/devise.rb"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/uploads", "public/system", "public/exports"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Ruby version / RVM
set :rvm1_ruby_version, '2.3.3@retrospring'

# Rollbar
set :rollbar_token, '35f65946f562414da66d0d48073f5290' # TODO: before publishing this repo (again) remove this token
set :rollbar_env, Proc.new { fetch :stage }
set :rollbar_role, Proc.new { :app }

# Create JS i18n files after precompiling assets
after 'deploy:assets:precompile', 'deploy:i18n_assets'

# Restart the app server after successful deploy
after 'deploy:cleanup', 'deploy:restart'
