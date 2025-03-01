# frozen_string_literal: true

class ReportFilter
  include CursorPaginatable

  define_cursor_paginator :cursored_results, :results

  KEYS = %i[
    user
    target_user
    type
  ].freeze

  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    scope = Report.where(resolved: false)
                  .order(:created_at)
                  .reverse_order

    params.each do |key, value|
      scope.merge!(scope_for(key, value)) if value.present?
    end

    scope
  end

  private

  def scope_for(key, value)
    case key.to_s
    when "user"
      Report.joins(:user)
            .where(users: { screen_name: value })
    when "target_user"
      Report.joins(:target_user)
            .where(users: { screen_name: value })
    when "type"
      Report.where("LOWER(type) = ?", "reports::#{value}")
    end
  end
end
