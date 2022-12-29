# frozen_string_literal: true

module UseCase
  module DataExport
    class MuteRules < UseCase::DataExport::Base
      def files = {
        "mute_rules.json" => json_file!(
          mute_rules: user.mute_rules.map(&method(:collect_mute_rule))
        )
      }

      def collect_mute_rule(mute_rule)
        {}.tap do |h|
          column_names(::MuteRule).each do |field|
            h[field] = mute_rule[field]
          end
        end
      end
    end
  end
end
