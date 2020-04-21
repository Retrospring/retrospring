# frozen_string_literal: true

module CursorPaginatable
  extend ActiveSupport::Concern

  module ClassMethods
    # Defines a cursor paginator.
    #
    # This method will define a new method +name+, which accepts the keyword
    # arguments +last_id+ for defining the last id the cursor will operate on,
    # and +size+ for the amount of records it should return.
    #
    # @param name [Symbol] The name of the method for the cursor paginator
    # @param scope [Symbol] The name of the method which returns an
    #   ActiveRecord scope.
    #
    # @example
    # class User
    #   has_many :answers
    #
    #   include CursorPaginatable
    #   define_cursor_paginator :cursored_answers, :recent_answers
    #
    #   def recent_answers
    #     self.answers.order(:created_at).reverse_order
    #   end
    # end
    def define_cursor_paginator(name, scope, default_size: APP_CONFIG.fetch('items_per_page'))
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}(*args, last_id: nil, size: #{default_size}, **kwargs)
          s = self.#{scope}(*args, **kwargs).limit(size)
          s = s.where(s.arel_table[:id].lt(last_id)) if last_id.present?
          s
        end
      RUBY
    end
  end
end
