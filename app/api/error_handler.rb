class ErrorHandler < Grape::Middleware::Base
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
        result: "ERR_UNEXPECTED",
        code: status,
        success: false
      }

      if status == 404
        payload[:result] = "ERR_RECORD_NOT_FOUND"
      end

      if status == 418
        payload[:result] = "ERR_UNIMPLEMENTED"
      end

      unless Rails.env.production?
        payload[:trace] = e.backtrace[0,10]
        payload[:exception] = e.inspect
      end

      throw :error, :message => payload, :status => status
    end
  end
end
