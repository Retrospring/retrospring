class Metrics < Grape::Middleware::Base
  def current_application
    env["api.endpoint"].current_application
  end

  def before
    return if current_application.nil?

    stopwatch_start

    record_db if defined? ::ActiveRecord
  end

  def after
    return if current_application.nil?

    stopwatch_stop

    ApplicationMetric.create parameters(::Rack::Request.new(env), response)
    nil
  end

protected
  def parameters(req, res)
    {
      application:   current_application,
      req_path:      req.path,
      req_params:    req.params.to_json,
      req_method:    req.request_method,
      res_timespent: stopwatch.to_i,
      db_time:        @db_duration,
      db_calls:       @db_calls,
      res_status:    res.status
    }
  end

private
  def stopwatch_start
    @start_time = Time.now
  end

  def stopwatch_stop
    @end_time = Time.now
  end

  def stopwatch
    if @end_time
      @end_time - @start_time
    else
      Time.now - @start_time
    end
  end

  def record_db
    @db_calls = 0
    @db_duration = 0
    ::ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
      event = ::ActiveSupport::Notifications::Event.new(*args)
      @db_duration += event.duration.to_i
      @db_calls += 1
    end
  end
end
