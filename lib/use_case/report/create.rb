# frozen_string_literal: true

module UseCase
  module Report
    class Create < UseCase::Base
      option :reporter_id, type: Types::Coercible::Integer
      option :object_id, type: Types::Coercible::String
      option :object_type, type: Types::Coercible::String
      option :reason, type: Types::Coercible::String, optional: true

      def call
        do_checks!

        report = create_report

        {
          status:   201,
          resource: report,
        }
      end

      private

      def do_checks!
        check_object_type
        check_object_exists
      end

      def check_object_type
        valid_types = %w[answer comment question user]
        return if valid_types.include?(object_type.downcase)

        raise Errors::BadRequest.new("Unknown object type")
      end

      def check_object_exists
        object
      end

      def create_report
        target_user = if object.instance_of?(::User)
                        object
                      elsif object.respond_to? :user
                        object.user
                      end

        existing = ::Report.find_by(type: "Reports::#{object.class}", target_id: object.id, user_id: reporter.id, target_user_id: target_user&.id, resolved: false)
        return unless existing.nil?

        ::Report.create(type: "Reports::#{object.class}", target_id: object.id, user_id: reporter.id, target_user_id: target_user&.id, reason: reason)
      end

      def object
        @object ||= case object_type.strip.capitalize
                    when "User"
                      ::User.find_by_screen_name!(object_id)
                    when "Question"
                      ::Question.find(object_id)
                    when "Answer"
                      ::Answer.find(object_id)
                    when "Comment"
                      ::Comment.find(object_id)
                    end
      end

      def reporter
        @reporter ||= ::User.find(reporter_id)
      end
    end
  end
end
