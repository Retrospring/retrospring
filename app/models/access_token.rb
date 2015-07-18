# I should've done this a long time ago
class AccessToken < ActiveRecord::Base
  include Doorkeeper::AccessTokenMixin
  self.table_name = "oauth_access_tokens"
end
