# frozen_string_literal: true

module Retrospring
  module Metrics
    PROMETHEUS = Prometheus::Client.registry

    # avoid re-registering metrics to make autoreloader happy during dev:
    class << self
      %i[counter gauge histogram summary].each do |meth|
        define_method meth do |name, *args, **kwargs|
          PROMETHEUS.public_send(meth, name, *args, **kwargs)
        rescue Prometheus::Client::Registry::AlreadyRegisteredError
          raise unless Rails.env.development?

          PROMETHEUS.unregister name
          retry
        end
      end
    end

    VERSION_INFO = gauge(
      :retrospring_version_info,
      docstring:     "Information about the currently running version",
      labels:        [:version],
      preset_labels: {
        version: Retrospring::Version.to_s,
      },
    ).tap { _1.set 1 }

    QUESTIONS_ASKED = counter(
      :retrospring_questions_asked_total,
      docstring: "How many questions got asked",
      labels:    %i[anonymous followers generated],
    )

    QUESTIONS_ANSWERED = counter(
      :retrospring_questions_answered_total,
      docstring: "How many questions got answered",
    )

    COMMENTS_CREATED = counter(
      :retrospring_comments_created_total,
      docstring: "How many comments got created",
    )

    USERS_CREATED = counter(
      :retrospring_users_created_total,
      docstring: "How many users got created",
    )

    USERS_DESTROYED = counter(
      :retrospring_users_destroyed_total,
      docstring: "How many users deleted their accounts",
    )

    # metrics from Sidekiq::Stats.new
    SIDEKIQ = {
      processed:      gauge(
        :sidekiq_processed,
        docstring: "Number of jobs processed by Sidekiq",
      ),
      failed:         gauge(
        :sidekiq_failed,
        docstring: "Number of jobs that failed",
      ),
      scheduled_size: gauge(
        :sidekiq_scheduled_jobs,
        docstring: "Number of jobs that are enqueued",
      ),
      retry_size:     gauge(
        :sidekiq_retried_jobs,
        docstring: "Number of jobs that are being retried",
      ),
      dead_size:      gauge(
        :sidekiq_dead_jobs,
        docstring: "Number of jobs that are dead",
      ),
      processes_size: gauge(
        :sidekiq_processes,
        docstring: "Number of active Sidekiq processes",
      ),
      queue_enqueued: gauge(
        :sidekiq_queues_enqueued,
        docstring: "Number of enqueued jobs per queue",
        labels:    %i[queue],
      ),
    }.freeze
  end
end
