# This ASS runscript starts justask in development mode on a FreeBSD host.
# (c) 2015 nilsding
# This file is a modification of https://github.com/retrospring/ass/blob/master/scripts/example-rails.rb

Runscript.new do
  before_start do
    # set Rails environment to development
    setenv :RAILS_ENV, 'development'

    # install bundle
    sh %|bundle install --without production mysql|

    # edit and copy example justask config
    sh %|sed -i .old -e 's/justask.rrerr.net/justask.local/g' -e 's/"Anonymous"/"Arno Nym"/g' -e 's/enabled: tru/enabled: fals/g' ./config/justask.yml.example|
    sh %|cp ./config/justask.yml.example ./config/justask.yml|

    # edit and copy postgres database config
    sh %|sed -i .old -e 's/_production/_producktion/g' -e 's/justask_development/ja_devel/g' -e 's/username: postgres/username: nilsding/g' ./config/database.yml.postgres|
    sh %|cp ./config/database.yml.postgres ./config/database.yml|

    # migrate the database
    sh %|bundle exec rake db:migrate|
  end

  start do
    sh %|bundle exec rails server -b 127.0.0.1 -p 16933|, pid: :rails, wait: false
  end

  stop do
    unset :RAILS_ENV
    kill :rails, with: :SIGINT
  end
end
