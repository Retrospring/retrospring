# justask [![build status](https://ci.rrerr.net/projects/9/status.png?ref=master)](https://ci.rrerr.net/projects/9?ref=master)

## Requirements

- UNIX-like system (Linux, *BSD, ...)
- ruby 1.9.3+
- Bundler
- PostgreSQL or MySQL

## Installation

### Database

#### PostgreSQL

    $ sudo -u postgres psql -d template1
    template1=# CREATE USER justask CREATEDB;
    template1=# CREATE DATABASE justask_production OWNER justask;
    template1=# \q

Try connecting to the database:

    $ psql -U justask -d justask_production

#### MySQL

    $ mysql -u root -p
    # change 'hack me' in the command below to a real password
    mysql> CREATE USER 'justask'@'localhost' IDENTIFIED BY 'hack me';
    mysql> SET storage_engine=INNODB;
    mysql> CREATE DATABASE IF NOT EXISTS `justask_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
    mysql> GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES ON `justask_production`.* TO 'justask'@'localhost';
    mysql> \q

Try connecting to the database:

    $ mysql -u justask -p -D justask_production

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

    # PostgreSQL only:
    $ cp config/database.yml.postgres config/database.yml

    # MySQL only:
    $ cp config/database.yml.mysql config/database.yml

    # MySQL and remote PostgreSQL only:
    $ vi config/database.yml

    # Both:
    # Make database.yml readable only for you
    chmod o-rwx config/database.yml

#### Install Gems

    # For PostgreSQL (note: the option says "without ... mysql")
    $ bundle install --deployment --without development test mysql

    # Or, if you use MySQL
    $ bundle install --deployment --without development test postgres

#### Initialize Database

    $ bundle exec rake db:migrate RAILS_ENV=production

#### Compile Assets

    $ bundle exec rake assets:precompile RAILS_ENV=production

#### Run the server

    # Production mode:
    $ mkdir -p ./tmp/sockets/
    $ bundle exec unicorn -E production -l unix:./tmp/sockets/justask.sock

    # Development mode:
    $ bundle exec rails server

Create an account on your justask installation.

To make yourself an admin, just execute:

    $ bundle exec rake 'justask:admin[your_username]' RAILS_ENV=production

If you want to remove admin status from a certain user, you can do this:

    $ bundle exec rake 'justask:deadmin[get_rekt]' RAILS_ENV=production

