namespace :deploy do
  task :start do
    on roles(:all) do
puts "------- skip start"
next
      rvm_prefix = "#{fetch(:rvm1_auto_script_path)}/rvm-auto.sh #{fetch(:rvm1_ruby_version)}"
      execute :tmux, 'new-session',
              '-d',
              '-s', 'retrospring',
              '-n', 'retrospring',
              '-c', '/usr/home/justask/apps/retrospring/current',
              "'#{rvm_prefix} bundle exec foreman start'"
    end
  end

  task :stop do
    on roles(:all) do
puts "------- skip stop"
next
      execute :sh, '-c', '\'tmux list-panes -t retrospring -F "#{pane_pid}" | xargs kill\''
    end
  end

  desc 'Restart the server'
  task :restart do
    on roles(:all) do
puts "------- skip restart"
next
      info 'Restarting application server'
      invoke('deploy:stop')

      info 'Waiting 5 seconds'
      sleep 5

      invoke('deploy:start')
    end
  end
end
