class Metrics < Grape::Middleware::Base
  def before
    return if current_application.nil?

    stopwatch_start

    record_db if defined? ActiveRecord
  end

  def after
    return if current_application.nil?

    stopwatch_stop

    ApplicationMetric.create parameters(request, response)
  end

  def parameters(req, res)
    {
      application: current_application,
      path:        req.path,
      params:      req.params.to_json,
      method:      req.request_method,
      spent:       stopwatch.to_i,
      dbtime:      @db_duration,
      dbcalls:     @db_calls,
      status:      res.status
    }
  end

  def stopwatch_start
    @start_time ||= Time.now
  end

  def stopwatch_stop
    @end_time ||= Time.now
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
    ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
      @db_duration += event.duration.to_i
      @db_calls += 1
    end
  end
end
