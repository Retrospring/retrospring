class API::Sleipnir < API::Hub
  version 'sleipnir'
  mount API::Sleipnir::Setting
  mount API::Sleipnir::User
  mount API::Sleipnir::Answer
  mount API::Sleipnir::Question
  mount API::Sleipnir::Comment
  mount API::Sleipnir::Discover
  mount API::Sleipnir::Group
  mount API::Sleipnir::Inbox
  mount API::Sleipnir::Notification

  add_swagger_documentation base_path: '/api',
    version: 'sleipnir',
    hide_format: true,
    hide_documentation_path: true,
    mount_path: '/dev/api',
    markdown: GrapeSwagger::Markdown::KramdownAdapter,
    info: {
      title: "Retrospring API v1  / Sleipnir",
      description: "The first iteration of the retrospring OAuth API."
    }
end
