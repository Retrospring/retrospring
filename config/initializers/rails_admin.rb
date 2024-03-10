# frozen_string_literal: true

# workaround to get pagination right
RailsAdmin.config do |config|
  config.asset_source = :sprockets
  config.main_app_name = %w[justask Kontrollzentrum]
  config.parent_controller = "::ApplicationController"

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
    Reaction
    Answer
    AnonymousBlock
    Comment
    List
    ListMember
    InboxEntry
    MuteRule
    Notification
    Profile
    Question
    Relationship
    Relationships::Follow
    Relationships::Block
    Relationships::Mute
    Report
    Service
    Services::Twitter
    Theme
    User
    UserBan
    WebPushSubscription
  ]

  # set up icons for some models
  {
    "AnonymousBlock"        => "user-secret",
    "Answer"                => "exclamation",
    "Reaction"              => "smile",
    "Comment"               => "comment",
    "InboxEntry"            => "inbox",
    "List"                  => "list",
    "ListMember"            => "users",
    "MuteRule"              => "volume-mute",
    "Notification"          => "bell",
    "Profile"               => "id-card",
    "Question"              => "question",
    "Relationship"          => "people-arrows",
    "Relationships::Block"  => "user-slash",
    "Relationships::Follow" => "user-friends",
    "Relationships::Mute"   => "volume-mute",
    "Report"                => "exclamation-triangle",
    "Service"               => "network-wired",
    "Services::Twitter"     => "dumpster-fire",
    "Theme"                 => "paint-brush",
    "User"                  => "user",
    "UserBan"               => "user-lock",
    "WebPushSubscription"   => "dot-circle"
  }.each do |model, icon|
    config.model model do
      navigation_icon "fa fa-fw fa-#{icon} me-1"
    end
  end

  # set up custom parents for certain models to group them nicely together
  {
    "AnonymousBlock"      => User,
    "InboxEntry"          => User,
    "List"                => User,
    "MuteRule"            => User,
    "Notification"        => User,
    "Profile"             => User,
    "Relationship"        => User,
    "Service"             => User,
    "Theme"               => User,
    "WebPushSubscription" => User,

    "ListMember"          => List
  }.each do |model, parent_model|
    config.model model do
      parent parent_model
    end
  end

  # create groups inside nav tree
  {
    "User content" => %w[
      Answer
      Appendable
      Comment
      Reaction
      Question
      User
    ],
    "Global"       => %w[
      Report
      UserBan
    ]
  }.each do |label, models|
    models.each do |model|
      config.model model do
        navigation_label label
      end
    end
  end
end
