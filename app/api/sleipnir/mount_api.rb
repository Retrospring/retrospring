class Sleipnir::MountAPI < Grape::API
  format :json
  version :sleipnir, cascade: false
  default_error_formatter :json
  content_type :json, 'application/json'
  use WineBouncer::OAuth2

  mount Sleipnir::UserAPI => '/'

  add_swagger_documentation base_path: '/api/sleipnir',
    version: 'sleipnir',
    hide_format: true,
    hide_documentation_path: true,
    mount_path: '/api',
    markdown: GrapeSwagger::Markdown::RedcarpetAdapter,
    info: {
      title: "Retrospring API v1  / Sleipnir",
      description: "The first iteration of the retrospring OAuth API."
    }

  route :any, '*path' do
    Rack::Response.new({message: "Not found"}.to_json, 404).finish
  end
end
