# frozen_string_literal: true

require "use_case/data_export/base"

module UseCase
  module DataExport
    class InboxEntries < UseCase::DataExport::Base
      def files = {
        "inbox_entries.json" => json_file!(
          inbox_entries: user.inboxes.map(&method(:collect_inbox_entry))
        )
      }

      def collect_inbox_entry(inbox_entry)
        {}.tap do |h|
          column_names(::Inbox).each do |field|
            h[field] = inbox_entry[field]
          end
        end
      end
    end
  end
end
