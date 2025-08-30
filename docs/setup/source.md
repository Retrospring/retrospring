This page details the steps required to set up a production environment from source.

> [!NOTE]
> This documentation has been heavily adopted from [Mastodons 'Installing from source' documentation](https://docs.joinmastodon.org/admin/install/)

## Pre-requisites

* A server running **Ubuntu 24.04** or **Debian 12** that you have root access to
* A domain name (or subdomain) for your Retrospring site, like `example.com`
* A mail delivery service or an SMTP server

### System repositories

Make sure curl, wget, gnupg, apt-transport-https, lsb-release and ca-certificates are installed first:

```shell
apt install -y curl wget gnupg apt-transport-https lsb-release ca-certificates
```

#### Node.js

```shell
mkdir -p /etc/apt/keyrings && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
```

Retrospring uses Yarn as a package manager:

```shell
npm install -g yarn
```

### System packages

```shell
apt-get install -y --no-install-recommends build-essential libpq-dev postgresql-client libxml2-dev libxslt1-dev libmagickwand-dev imagemagick libidn11-dev libicu-dev libjemalloc-dev libyaml-dev libreadline-dev libssl-dev libjemalloc-dev redis-server redis-tools
```

### Installing Ruby

We will use rbenv to manage Ruby versions as it simplifies obtaining the correct versions and updating them when new releases are available. Since rbenv needs to be installed for an individual Linux user, we must first create the user account under which Retrospring will run:

```shell
adduser --disabled-login retrospring
usermod -s /bin/bash retrospring
```

We can then switch to the user:

```shell
su - retrospring
```

And proceed to install rbenv and rbenv-build:

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
exec bash
```
```bash
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```

Once this is done, we can install the correct Ruby version:

```shell
RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install 3.2.3
rbenv global 3.2.3
```

We’ll also need to install the bundler:

```shell
gem install bundler --no-document
```

Return to the root user:

```shell
exit
```

## Setup

### Setting up PostgreSQL

#### Performance configuration (optional)

For optimal performance, you may use [pgTune](https://pgtune.leopard.in.ua/#/) to generate an appropriate configuration and edit values in `/etc/postgresql/16/main/postgresql.conf` before restarting PostgreSQL with `systemctl restart postgresql`

#### Creating a user

You will need to create a PostgreSQL user that Retrospring could use. It is easiest to go with “ident” authentication in a simple setup, i.e. the PostgreSQL user does not have a separate password and can be used by the Linux user with the same username.

Open the prompt:

```shell
sudo -u postgres psql
```

In the prompt, execute:

```sql
CREATE USER retrospring CREATEDB;
CREATE DATABASE retrospring_production OWNER retrospring;
\q
```

Done!

### Setting up nginx

Copy the configuration template for nginx from the Retrospring directory:

```bash
cp /home/retrospring/retrospring/docs/nginx.conf /etc/nginx/sites-available/retrospring
ln -s /etc/nginx/sites-available/retrospring /etc/nginx/sites-enabled/retrospring
rm /etc/nginx/sites-enabled/default
```

Then edit `/etc/nginx/sites-available/retrospring` and follow the comments and adjusts domains and paths according to your setup.

Reload nginx for the changes to take effect:

```bash
systemctl reload nginx
```

### Setting up Retrospring

It is time to download the Retrospring code. Switch to the retrospring user:

```shell
su - retrospring
```

#### Checking out the code

Use git to download the latest stable release of Retrospring:

```shell
git clone https://github.com/Retrospring/retrospring.git && cd retrospring
```

Visit [the latest releases page](https://github.com/retrospring/retrospring/releases/latest) and check it out (ex. `2024.0811.1`)

```shell
git checkout 2024.0811.01
```

#### Installing dependencies

Now to install Ruby and JavaScript dependencies:

```shell
bundle install --deployment --without development test mysql
yarn install --frozen-lockfile
```

#### Configuring Retrospring

##### Database configuration

You can either configure Retrosprings database connection via environment variables:

```shell
export DATABASE_URL=postgres://[username]:[password]@[host]/[dbname]?pool=25
```

...or with copying the `config/database.yml.postgres` to `config/database.yml` and adjusting its contents:

```shell
cp config/database.yml.postgres config/database.yml
$EDITOR config/database.yml
```

##### Application configuration

Copy the configuration file `config/justask.yml.example` to `config/justask.yml` and adjust its contents:

```
cp config/justask.yml.example config/justask.yml
$EDITOR config/justask.yml
```
##### SMTP configuration

It is recommended to read up on the chapter [Action Mailer configuration](https://guides.rubyonrails.org/action_mailer_basics.html#action-mailer-configuration) from the Ruby on Rails guides.

E-Mail sending configuration is currently done via environment variables, the following ones are available:

| Rails `:smtp_settings` key | Retrospring environent variable |
|----------------------------|---------------------------------|
| `:address`                 | `SMTP_SERVER`                   |
| `:port`                    | `SMTP_PORT`                     |
| `:user_name`               | `SMTP_LOGIN`                    |
| `:password`                | `SMTP_PASSWORD`                 |
| `:domain`                  | `SMTP_DOMAIN` (or `LOCAL_DOMAIN` as fallback) |
| `:authentication`          | `SMTP_AUTH_METHOD`
| `:ca_file`                 | `SMTP_CA_FILE` (`/etc/ssl/certs/ca-certificates.crt` as default) |
| `:openssl_verify_mode`     | `SMTP_OPENSSL_VERIFY_MODE`      |
| `:enable_starttls`         | `SMTP_ENABLE_STARTTLS` (`always`, `never` or `auto`) |
| `:enable_starttls_auto`    | `true` when `SMTP_ENABLE_STARTTLS` is set to `auto`, otherwise `false` |
| `:tls`                     | `SMTP_TLS` (any value, or `true` enables this) |
| `:ssl`                     | `SMTP_SSL` (any value, or `true` enables this) |

Additionally, you can configure the Action Mailer delivery method using `SMTP_DELIVERY_METHOD`, the default is `sendmail`.

#### Setup tasks

##### Generate secret key

This command creates a secret key used for encryption/hashing across the application:

```shell
RAILS_ENV=production bundle exec rails credentials:edit
```

> [!NOTE]
> This command only needs to be run once per setup, the other setup tasks need to be run after each deployment.

##### Export locales

This exports the locales for use in JavaScript code:

```shell
RAILS_ENV=production bundle exec i18n export
```

##### Initialize the database

This command creates the database schema:

```shell
RAILS_ENV=production bundle exec rake db:migrate
```

##### Precompile assets

This command compiles all JavaScript/Stylesheet assets:

```shell
RAILS_ENV=production bundle exec rake assets:precompile
```

#### Running Retrospring

##### Manually

You can start Retrospring manually using `foreman`.

If it is not installed yet, install it using Bundler with:

```shell
gem install foreman
```

Then just start Retrospring using:
```shell
foreman start
```

##### As systemd services

Copy the example Retrospring service files from the repository:

```shell
cp /home/retrospring/retrospring/docs/systemd/retrospring-*.service /etc/systemd/system/
```

If you deviated from the defaults at any point, check that the username and paths are correct:

```
$EDITOR /etc/systemd/system/retrospring-*.service
```

Finally, start and enable the new systemd services:
```shell
systemctl daemon-reload
systemctl enable --now retrospring-web retrospring-sidekiq
```

They will now automatically start at boot.

----

You should now be able to visit your configured domain and see the Retrospring homepage!

Continue to [First Steps](/docs/setup/first-steps.md) for setting up an administrator account and more. 
