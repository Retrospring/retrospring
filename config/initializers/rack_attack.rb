# frozen_string_literal: true

class Rack::Attack
  class Request < ::Rack::Request
    def authenticated_user_id
      @env.dig("rack.session", "warden.user.user.key", 0, 0)
    end

    def unauthenticated?
      !authenticated_user_id
    end

    def remote_ip
      @remote_ip ||= (@env["action_dispatch.remote_ip"] || ip).to_s
    end
  end

  throttle("throttle_unauthenticated_asking", limit: 3, period: 1.minutes) do |req|
    req.remote_ip if req.path == "/ajax/ask" && req.unauthenticated?
  end

  throttle("throttle_authenticated_asking", limit: 30, period: 15.minutes) do |req|
    req.authenticated_user_id if req.path == "/ajax/ask" && !req.unauthenticated?
  end
end
