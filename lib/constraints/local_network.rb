# frozen_string_literal: true

module Constraints
  module LocalNetwork
    module_function

    SUBNETS = %w[
      10.0.0.0/8
      127.0.0.0/8
      172.16.0.0/12
      192.168.0.0/16
    ].map { IPAddr.new(_1) }.freeze

    def matches?(request)
      SUBNETS.find do |net|
        net.include? request.remote_ip
      rescue
        false
      end
    end
  end
end
