# I should've done this a long time ago
class Application < ActiveRecord::Base
  include Doorkeeper::ApplicationMixin
  include Concerns::ApplicationExtension
  self.table_name = "oauth_applications"
end
