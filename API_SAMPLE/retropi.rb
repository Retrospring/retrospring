require 'rubygems'
require 'bundler/setup'
require 'oauth2'
require 'yaml'

CONFIG = YAML.load_file './config.yml'

client = OAuth2::Client.new(CONFIG['client_id'], CONFIG['client_secret'], :site => CONFIG['site_host'])

# Very dirty hack, used mostly by me (Yuki) to test if OAuth works

if CONFIG['access_code'].length == 0
  puts "get access_code from\n#{client.auth_code.authorize_url(:scope => CONFIG['scopes'].join(' '), :redirect_uri => CONFIG['redirect'])}\n"
elsif CONFIG['access_token'] === false
  token = client.auth_code.get_token(CONFIG["access_code"], :scope => CONFIG['scopes'].join(' '), :redirect_uri => CONFIG['redirect'])
  CONFIG['access_token'] = token.to_hash
  File.open('config.yml', 'w') { |f| f.write(CONFIG.to_yaml) }
  puts "Access token:\n#{token.to_hash}\nrerun\n"
else
  token = OAuth2::AccessToken.from_hash(client, CONFIG["access_token"])
  puts token.get('/api/sleipnir/user/me.json').body
end
