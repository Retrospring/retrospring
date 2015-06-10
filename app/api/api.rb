class API < Grape::API
  format :json
  content_type :json, 'application/json'
  content_type :msgpack, 'application/x-msgpack'

  use API::ErrorHandler

  before do
    header['Access-Control-Allow-Origin'] = '*'
    header['Access-Control-Request-Method'] = '*'
  end

  helpers do
    def current_token
      doorkeeper_access_token
    end

    def current_user
      resource_owner
    end

    def current_application
      return nil if current_token.nil?
      current_token.application
    end

    def current_scopes
      return nil if current_token.nil?
      current_token.scopes
    end
  end

  use ::WineBouncer::OAuth2

  use Grape::Middleware::ThrottleMiddleware, cache: Redis.new(url: APP_CONFIG['redis_url']), user_key: ->(env) do
    context = env['api.endpoint']
    user = unless context.current_token.nil?
      "#{context.current_application.id}-#{context.current_user.id}"
    else
      "#{env['REMOTE_ADDR']}"
    end
  end

  use API::Metrics

  get do
    status 200
    result = {
      notes: "This page is a list of API entry points, true means they are active, false means they are depricated. You can find their swagger documentation at /api/:entry/swagger_doc.json",
      apis: {
        sleipnir: true
      }
    }
  end

  mount Sleipnir::MountAPI

  route :any, '*path' do
    status 404
    {message: "Not found", status: 404}
  end
end
