server 'rrerr.net', user: 'justask', roles: %w{web app}

set :ssh_options, {
  keys: %w(~/.ssh/id_rsa),
  forward_agent: false,
  auth_methods: %w(publickey)
}
