class Sleipnir::Entities::ReportEntity < Sleipnir::Entities::BaseEntity
  expose :id, format_with: :strid

  expose :type, as: :type
  expose :target do |report, options|
    if options[:payload_id]
      report.target_id
    else
      case report.type
      when 'Reports::Answer'
        Sleipnir::Entities::Answer.represent report.target, options
      when 'Reports::Comment'
        Sleipnir::Entities::Comment.represent report.target, options
      when 'Reports::Question'
        Sleipnir::Entities::Question.represent report.target, options
      when 'Reports::User'
        Sleipnir::Entities::User.represent report.target, options
      else
        { id: report.target_id, error: "ERR_UNKNOWN_TYPE", type: report.type, payload: nil, user: nil}
      end
    end
  end
end
