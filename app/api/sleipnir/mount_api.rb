class Sleipnir::MountAPI < Grape::API
  format :json
  version :sleipnir, cascade: false
  default_error_formatter :json

  mount Sleipnir::UserAPI

  add_swagger_documentation base_path: '/api',
    hide_format: false,
    hide_documentation_path: true,
    api_version: "sleipnir",
    mount_path: "/develop",
    root_base_path: "http#{APP_CONFIG["https"] && "s" || ""}://#{APP_CONFIG["hostname"]}/api",
    markdown: GrapeSwagger::Markdown::RedcarpetAdapter,
    info: {
      title: "Retrospring API v1  / Sleipnir",
      description: "The first iteration of the retrospring OAuth API."
    }
end
