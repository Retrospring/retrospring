# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
start = Time.now
Rails.application.initialize!
puts 'processing time of Rails.application.initialize!: ' + "#{(Time.now - start).round(3).to_s.ljust(5, '0')}s".light_green
