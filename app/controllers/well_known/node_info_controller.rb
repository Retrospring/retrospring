# frozen_string_literal: true

class WellKnown::NodeInfoController < ApplicationController
  def discovery
    expires_in 3.days, public: true

    render json: {
      links: [
        rel:  "http://nodeinfo.diaspora.software/ns/schema/2.1",
        href: node_info_url
      ]
    }
  end

  def nodeinfo
    expires_in 30.minutes, public: true

    render json: {
      version:           "2.1",
      software:          software_info,
      protocols:         %i[],
      services:          {
        inbound:  inbound_services,
        outbound: outbound_services
      },
      usage:             usage_stats,
      # We don't implement this so we can always return true for now
      openRegistrations: true,
      metadata:          {}
    }
  end

  private

  def software_info
    {
      name:       "Retrospring",
      version:    Retrospring::Version.to_s,
      repository: "https://github.com/Retrospring/retrospring"
    }
  end

  def usage_stats
    {
      users: {
        total: User.count
      }
    }
  end

  def inbound_services = []

  def outbound_services
    {
      "twitter" => APP_CONFIG.dig("sharing", "twitter", "enabled")
    }.select { |_service, available| available }.keys
  end
end
