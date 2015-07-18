class API < Grape::API
  CORS_SCHEME = ['http', 'https'].freeze

  format :json
  content_type :json, 'application/json'
  content_type :msgpack, 'application/x-msgpack'

  use API::ErrorHandler

  before do
    header['Access-Control-Allow-Origin']   = '*'
    header['Access-Control-Request-Method'] = 'GET'
    header['Access-Control-Allow-Headers']  = 'Content-Type'
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

  before do
    # adjust CORS headers if application is present
    unless current_application.nil?
      unless env['HTTP_ORIGIN'].nil?
        origin = env['HTTP_ORIGIN'].downcase # origin header present
        origins = []
        redirect_uris = current_application.redirect_uri.downcase.split
        if redirect_uris.index('urn:ietf:wg:oauth:2.0:oob').nil?
          header['Access-Control-Allow-Origin'] = nil

          redirect_uris.each do |r|
            begin
              uri = URI.parse r

              next if CORS_SCHEME.index(uri.scheme).nil?

              local_origin = "#{uri.scheme}://#{uri.host}"

              if (uri.scheme == 'https' and uri.port != 443) or (uri.scheme == 'http' and uri.port != 80)
                local_origin += ":#{uri.port}"
              end

              origins.push local_origin
            rescue
              next
            end
          end

          if origins.index(origin).nil?
            present({success: true, error: 302, result: "ERR_INVALID_OAUTH_ORIGIN"})
            return false # break route, origin doesn't match.
          else
            header['Access-Control-Allow-Origin'] = origin
          end
        end
      end

      # everything is GET only, 'write' and 'rewrite' actually allows for any method.
      unless current_scopes.nil? or (current_scopes.to_a.index('write').nil? and current_scopes.to_a.index('rewrite').nil?)
        header['Access-Control-Request-Method'] = '*'
      end
    end
  end

  use ::WineBouncer::OAuth2

  use Grape::Middleware::ThrottleMiddleware, expires_header: 'X-Rate-Limit-Reset', limit_header: 'X-Rate-Limit-Limit', remaining_header: 'X-Rate-Limit-Remaining', cache: Redis.new(url: APP_CONFIG['redis_url']), user_key: ->(env) do
    context = env['api.endpoint']
    user = unless context.current_token.nil?
      "app:#{context.current_application.id}user:#{context.current_user.id}"
    else
      nil
    end
  end

  if APP_CONFIG["api"]["metrics"]
    use API::Metrics
  end

  desc "simple info"
  get as: :root_api do
    status 200
    result = {
      notes: "This page is a list of API entry points, true means they are active, false means they are deprecated.",
      apis: {
        sleipnir: true
      }
    }
  end

  mount Sleipnir::MountAPI

  desc "Fallback 404"
  route :any, '*path', as: :fallback_fourohfour_api do
    status 404
    {success: false, code: 404, result: "ERR_NOT_FOUND"}
  end
end
