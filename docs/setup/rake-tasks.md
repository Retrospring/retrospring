# Rake Tasks

Different backend tasks affecting users or the database, besides `admin/deadmin` every task can be done on the web interface itself if you visit an users profile.

## User-related Tasks

**Adding/Removing Admin Status:**

    RAILS_ENV=production bundle exec rake 'justask:admin[your_username]' 
    RAILS_ENV=production bundle exec rake 'justask:deadmin[get_rekt]'

**Adding/Removing Moderator Status:**

    RAILS_ENV=production bundle exec rake 'justask:mod[someone_else]'
    RAILS_ENV=production bundle exec rake 'justask:demod[someone_else]'

