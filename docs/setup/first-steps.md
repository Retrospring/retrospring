Now visit your newly created instance at localhost:3000 or the configured hostname and register a new account.

### Administrator

To give yourself administrator permissions there's two supported ways:

**Rake**

```shell
RAILS_ENV=... bundle exec rake 'justask:admin[your_username]'
```

`your_username` being your username and `RAILS_ENV` being set to either `development` or `production`

_You can find more rake tasks to use [here](/docs/setup/rake-tasks.md)!_

**Rails Console**

```shell
RAILS_ENV=... bundle exec rails c
> @user = User.first
> @user.add_role :administrator
> @user.save!
```