namespace :storage do
  desc "Moves saved file uploads from paperclip to Active Storage"
  task :migrate do
    current_env = ENV.fetch('RAILS_ENV', 'development')
    if current_env == 'production'
      puts " !!! \e[31mRUNNING IN PRODUCTION\e[0m !!!"
      print "Type 'yes' to continue: "
      return unless gets.chomp == 'yes'
    end
    puts 'gjgj'

    # TODO: Write this
    # https://github.com/thoughtbot/paperclip/blob/master/MIGRATING.md#moving-files-on-a-remote-host-s3-azure-storage-gcs-etc
  end
end