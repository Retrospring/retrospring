# justask [![build status](https://ci.rrerr.net/projects/9/status.png?ref=master)](https://ci.rrerr.net/projects/9?ref=master)

## Requirements

- UNIX-like system (Linux, *BSD, ...)
- Ruby 2.0.0+
- Bundler
- PostgreSQL
- Redis

## Installation (production)

### Database

#### PostgreSQL

    $ sudo -u postgres psql -d template1
    template1=# CREATE USER justask CREATEDB;
    template1=# CREATE DATABASE justask_production OWNER justask;
    template1=# \q

Try connecting to the database:

    $ psql -U justask -d justask_production

### justask

#### Clone the Source

    $ git clone https://git.rrerr.net/nilsding/justask.git justask

#### Configure It

    # Change into the justask directory
    $ cd justask

    # Copy the example config
    $ cp config/justask.yml.example config/justask.yml

    # Edit the configuration file
    $ vi config/justask.yml

#### Database Configuration

    $ cp config/database.yml.postgres config/database.yml
    $ vi config/database.yml

    # Make database.yml readable only for you
    chmod o-rwx config/database.yml

#### Install Gems

    # Deployment:
    $ bundle install --deployment --without development test mysql

    # Development:
    $ bundle install --without production mysql

#### Initialize Database

    $ bundle exec rake db:migrate RAILS_ENV=production

#### Compile Assets

    $ bundle exec rake assets:precompile RAILS_ENV=production

#### Run the server

    # Production mode:
    $ foreman start

    # Development mode:
    $ bundle exec rails server

Create an account on your justask installation.

To make yourself an admin, just execute:

    $ bundle exec rake 'justask:admin[your_username]' RAILS_ENV=production

If you want to remove admin status from a certain user, you can do this:

    $ bundle exec rake 'justask:deadmin[get_rekt]' RAILS_ENV=production

Add/remove moderators:

    $ bundle exec rake 'justask:mod[someone_else]' RAILS_ENV=production
    $ bundle exec rake 'justask:demod[someone_else]' RAILS_ENV=production

Add/remove supporters:

    $ bundle exec rake 'justask:sup[someone_else]' RAILS_ENV=production
    $ bundle exec rake 'justask:desup[someone_else]' RAILS_ENV=production