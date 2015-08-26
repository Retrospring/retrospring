# workaround to get pagination right
if defined? WillPaginate
  Kaminari.configure do |config|
    config.page_method_name = :per_page_kaminari
  end
end

RailsAdmin.config do |config|

  config.main_app_name = [APP_CONFIG["site_name"], 'Kontrollzentrum']

  ## == Authentication ==
  config.authenticate_with do
    redirect_to main_app.root_path unless current_user.try :admin?
  end
  config.current_user_method(&:current_user)

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.included_models = %w[
    Answer
    Comment
    Group
    GroupMember
    Inbox
    Notification
    Question
    Relationship
    Report
    Service
    Services::Twitter
    Services::Tumblr
    Smile
    CommentSmile
    Subscription
    Theme
    User
    Application
    AccessGrant
    AccessToken
    ApplicationMetric
  ]
end
