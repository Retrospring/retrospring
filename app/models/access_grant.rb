# I should've done this a long time ago
class AccessGrant < ActiveRecord::Base
  include Doorkeeper::AccessGrantMixin
  self.table_name = "oauth_access_grants"
end
