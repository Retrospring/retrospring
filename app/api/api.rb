class API < Grape::API
  class APIErrorHandler < Grape::Middleware::Base
    def call!(env)
      @env = env
      begin
        @app.call(@env)
      rescue Exception => e
        source = e.class.to_s
        message = "OAuth2 Error #{e.to_s}" if source.match("WineBouncer::Errors")
        status = case
        when source.match("OAuthUnauthorizedError")
          401
        when source.match("OAuthForbiddenError")
          403
        when source.match('RecordNotFound'), e.message.match(/unable to find/i).present?
          404
        when source.match('TeapotError')
          418
        else
          (e.respond_to? :status) && e.status || 500
        end

        payload = {
          message: message || e.message || options[:default_message] || "Unexpected error",
          status: status
        }

        unless Rails.env.production?
          payload[:trace] = e.backtrace[0,10]
          payload[:exception] = e.inspect
        end

        throw :error, :message => payload, :status => status
      end
    end
  end

  format :json
  content_type :json, 'application/json'
  content_type :msgpack, 'application/x-msgpack'

  use APIErrorHandler

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


  ::APP_FAKE_OAUTH = Doorkeeper::Application.new(name: "Web", description: "#{APP_CONFIG["site_name"]} on the internets", homepage: "http#{APP_CONFIG["https"] && "s" || ""}://#{APP_CONFIG["hostname"]}#{APP_CONFIG["port"] && APP_CONFIG["port"] != 80 && ":#{APP_CONFIG["port"]}" || ""}", deleted: false, scopes: "-1")
  ::APP_FAKE_OAUTH.readonly!
end
