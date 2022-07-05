# frozen_string_literal: true

# workaround to get pagination right
RailsAdmin.config do |config|
  config.asset_source = :webpacker
  config.main_app_name = ['justask', 'Kontrollzentrum']
  config.parent_controller = '::ApplicationController'

  ## == Authentication ==
  config.authenticate_with do
    redirect_to main_app.root_path unless current_user&.has_role?(:administrator)
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
    Appendable
    Appendable::Reaction
    Answer
    AnonymousBlock
    Comment
    List
    ListMember
    Inbox
    MuteRule
    Notification
    Profile
    Question
    Relationship
    Relationships::Follow
    Relationships::Block
    Report
    Service
    Services::Twitter
    Theme
    User
    UserBan
  ]
end
