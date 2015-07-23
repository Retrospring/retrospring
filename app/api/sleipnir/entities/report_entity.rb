class Sleipnir::Entities::ReportEntity < Sleipnir::Entities::BaseEntity
  expose :id, format_with: :strid

  expose :votes

  expose :type, as: :type
  expose :target do |report, options|
    if options[:payload_id]
      report.target_id
    elsif report.target.nil?
      { id: report.target_id, error: "ERR_MALFORMED_TARGET" } # test?
    else
      case report.type
      when 'Reports::Answer'
        Sleipnir::Entities::AnswerEntity.represent report.target, options
      when 'Reports::Comment'
        Sleipnir::Entities::CommentEntity.represent report.target, options
      when 'Reports::Question'
        Sleipnir::Entities::QuestionEntity.represent report.target, options
      when 'Reports::User'
        Sleipnir::Entities::UserSlimEntity.represent report.target, options
      else
        { id: report.target_id, error: "ERR_UNKNOWN_TYPE" }
      end
    end
  end
end
