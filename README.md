# justask (aka. the software behind Retrospring)

This is the source code that powers Retrospring.  Yep, all of it.  Including
all the branches where we left off.

<!--
Except for the memes that happened 4 hours before the shutdown.  I've edited
it right on the server, without a special branch or something.  If you want
to, I can make a branch with all the modifications we made.
-->

## Requirements

- UNIX-like system (Linux, FreeBSD, ...)
- Ruby 2.0.0+
- Bundler
- PostgreSQL
- Redis (for Sidekiq)
- ImageMagick (for image processing)

## Installation (production)

We've installed justask on FreeBSD 10 using rvm.  What we also did was
creating a new, seperate user just for justask to run in.  On FreeBSD, this
is done with:

    # pw user add justask

### Database

At Retrospring, we were using PostgreSQL as the database backend.  The
software might work on MySQL too, but that was not tested.

Installation from Ports (using `portmaster`):

    # portmaster databases/postgresql93-server

#### PostgreSQL

    $ sudo -u postgres psql -d template1
    template1=# CREATE USER justask CREATEDB;
    template1=# CREATE DATABASE justask_production OWNER justask;
    template1=# \q

Try connecting to the database:

    $ psql -U justask -d justask_production

### nginx

See [docs/nginx.conf](https://github.com/nilsding/justask/blob/master/docs/nginx.conf)
for the configuration we use on Retrospring.

### justask

#### Clone the Source

    $ git clone https://github.com/nilsding/justask.git justask

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

Now, create an account on your justask installation.

To make yourself an admin, just execute:

    $ bundle exec rake 'justask:admin[your_username]' RAILS_ENV=production

If you want to remove admin status from a certain user, you can do this:

    $ bundle exec rake 'justask:deadmin[get_rekt]' RAILS_ENV=production

Add/remove moderators (this can also be done via the web interface by visiting an user as an admin):

    $ bundle exec rake 'justask:mod[someone_else]' RAILS_ENV=production
    $ bundle exec rake 'justask:demod[someone_else]' RAILS_ENV=production

Add/remove supporters (this can also be done via the web interface by visiting an user as an admin/mod):

    $ bundle exec rake 'justask:sup[someone_else]' RAILS_ENV=production
    $ bundle exec rake 'justask:desup[someone_else]' RAILS_ENV=production

Export user data:

    $ bundle exec rake 'justask:export[jdoe@example.tld]' RAILS_ENV=production

Find the user(s) with the most self-asked anonymous questions:

    $ bundle exec rake justask:loners

## The Official Retrospring Closedown Soundtrack™ (now redundant)

* [Scooter - Can't Stop The Hardcore](https://www.youtube.com/watch?v=nJ3bet-Y79w)
* [Darude - Sandstorm](https://www.youtube.com/watch?v=y6120QOlsfU)
* [Max Raabe - Oops I Did It Again](https://www.youtube.com/watch?v=qYr9kIyambE)

## License

AGPLv3.  
