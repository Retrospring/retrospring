class ApplicationMetric < ActiveRecord::Base
  validates :application, presence: true
  belongs_to :application, class_name: "Doorkeeper::Application"

  def request_parameters
    JSON.parse @req_params
  end

  def self.request(application_id, small = nil, large = nil)
    if small.nil?
      small = ApplicationMetric.timeseries_a application_id
    end

    if large.nil?
      large = ApplicationMetric.large_timeseries_a application_id
    end

    set = [{name: "Successes", data: []}, {name: "Fails", data: []}]
    large[0].merge(small[0]).each do |key, value|
      set[0][:data].push({x: key, y: value})
    end

    large[1].merge(small[1]).each do |key, value|
      set[1][:data].push({x: key, y: value})
    end

    set
  end

  # [[success], [error]]
  #  [timestamp, count]
  def self.ts_to_a(timeseries)
    ts = [{}, {}]
    timeseries.each do |series|
      #        nanotime
      if series.res_status != 200
        ts[1][series.created_at.to_i] = series["calls"]
        ts[0][series.created_at.to_i] = 0 if ts[0][series.created_at.to_i].nil?
      else
        ts[0][series.created_at.to_i] = series["calls"]
        ts[1][series.created_at.to_i] = 0 if ts[1][series.created_at.to_i].nil?
      end
    end
    ts
  end

  # TimeSeries =>
  #   "created_at"     -> Date
  #   "calls"          -> int
  #   "application_id" -> int
  #   "res_status"     -> int

  # https://wiki.postgresql.org/wiki/Round_time
  # SELECT DATE_TRUNC('hour', created_at) + INTERVAL '30 minute' * ROUND(DATE_PART('minute', created_at) / 30) AS created_at, COUNT(*) as calls, MIN(application_id) as application_id, "application_metrics"."res_status" FROM "application_metrics" WHERE (application_id = 7 AND created_at > '2014-12-15 04:38:12.047321') GROUP BY res_status, 1
  def self.timeseries(application_id, duration = 6.month, interval = 30, interval_type = 'minute')
    ApplicationMetric.select(ActiveRecord::Base.send(:sanitize_sql_array, ['DATE_TRUNC(\'hour\', created_at) + INTERVAL ? * ROUND(DATE_PART(?, created_at) / ?) AS created_at', [interval.to_s, interval_type].join(' '), interval_type, interval]))
                     .select('COUNT(*) as calls')
                     .select('application_id')
                     .select('res_status')
                     .where('application_id = ? AND created_at > ?', application_id, duration.ago)
                     .group('application_id, res_status, 1')
  end

  def self.timeseries_a(application_id, duration = 6.month, interval = 30, interval_type = 'minute')
    ApplicationMetric.ts_to_a(ApplicationMetric.timeseries(application_id, duration, interval, interval_type))
  end

  # SELECT DATE_TRUNC('month', created_at) as created_at, ROUND(COUNT(*) / 30) as calls, MIN(application_id) as application_id, "application_metrics"."res_status" FROM "application_metrics" WHERE (application_id = 7 AND created_at <= '2014-12-15 04:39:59.918047') GROUP BY res_status, 1
  def self.large_timeseries(application_id, duration = 6.month, dividend = 1440)
    #                                                                      1440 minutes in a day, one metric every 30 minute, 48 metrics in a day, 30 days in a month.
    ApplicationMetric.select('DATE_TRUNC(\'month\', created_at) as created_at')
                     .select(ActiveRecord::Base.send(:sanitize_sql_array, ['ROUND(COUNT(*) / ?) as calls', dividend])) # replace with .select('COUNT(*) as calls') if rickshaw can figure out how to normalize, otherwise keep as is.
                     .select('application_id')
                     .select('res_status')
                     .where('application_id = ? AND created_at <= ?', application_id, duration.ago)
                     .group('application_id, res_status, 1')
  end

  def self.large_timeseries_a(application_id, duration = 6.month, dividend = 1440)
    ApplicationMetric.ts_to_a(ApplicationMetric.large_timeseries(application_id, duration, dividend))
  end
end
