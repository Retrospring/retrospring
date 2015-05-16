module API
  class Hub < Grape::API
    default_format :json
    format :json
    default_error_formatter :json
    content_type :json, 'application/json'
    use ::WineBouncer::OAuth2

    rescue_from :all do |e|
      eclass = e.class.to_s
      message = "OAuth error: #{e.to_s}" if eclass.match('WineBouncer::Errors')

      status = case
      when eclass.match('OAuthUnauthorizedError')
        401
      when eclass.match('OAuthForbiddenError')
        403
      when eclass.match('RecordNotFound'), e.message.match(/unable to find/i).present?
        404
      else
        (e.respond_to? :status) && e.status || 500
      end

      opts = { error: "#{message || e.message}", status: status }
      opts[:trace] = e.backtrace[0,10] unless Rails.env.production?
      Rack::Response.new(opts.to_json, status, {
        'Content-Type' => "application/json",
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Request-Method' => '*',
      }).finish
    end

    mount API::Sleipnir

    route :any, '*path' do
      Rack::Response.new({error: "Not found", message: "Endpoint not found", status: 404}.to_json, 404).finish
    end
  end

  Root = Rack::Builder.new do
    use API::Logger
    run API::Hub
  end
