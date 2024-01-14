# frozen_string_literal: true

class InboxFilter
  include CursorPaginatable

  define_cursor_paginator :cursored_results, :results

  KEYS = %i[
    author
    anonymous
  ].freeze

  attr_reader :params, :user

  def initialize(user, params)
    @user = user
    @params = params
  end

  def results
    scope = @user.inboxes
                 .includes(:question, user: :profile)
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
    when "author"
      @user.inboxes.joins(question: [:user])
           .where(questions: { users: { screen_name: value }, author_is_anonymous: false })
    when "anonymous"
      @user.inboxes.joins(:question)
           .where(questions: { author_is_anonymous: true })
    end
  end
end
