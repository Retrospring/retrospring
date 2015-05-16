class Sleipnir::MountAPI < Grape::API
  format :json
  version :sleipnir, cascade: false
  default_error_formatter :json
  content_type :json, 'application/json'
  use ::WineBouncer::OAuth2

  mount Sleipnir::UserAPI => '/'

  add_swagger_documentation base_path: '/api',
    hide_format: true,
    hide_documentation_path: true,
    api_version: "sleipnir/0.0.1",
    markdown: GrapeSwagger::Markdown::RedcarpetAdapter,
    info: {
      title: "Retrospring API v1  / Sleipnir",
      description: "The first iteration of the retrospring OAuth API."
    }
end
