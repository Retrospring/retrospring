# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'justask'
set :repo_url, 'git@git.rrerr.net:justask/justask.git'
ask :branch, :master
set :deploy_to, '/home/justask/cap/'
set :scm, :git
set :format, :pretty
set :log_level, :debug

# RVM
set :rvm_type, :user
set :rvm_ruby_version, '2.0.0'

# Rails
set :conditionally_migrate, true

namespace :deploy do

  after :updated do

  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do

    end
  end

end
